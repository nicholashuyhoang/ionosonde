#!/usr/bin/env python3
import argparse
import matplotlib

import numpy as n
import matplotlib.pyplot as plt
import prc_lib as p
import glob
import os
import time
import re

import stuffr
import sweep
import h5py
import iono_config
import scipy.constants as c
from datetime import datetime, timedelta

import sys
matplotlib.use("Agg")


def save_raw_data(fname="tmp.h5",
                  t0=0,
                  z_all=0,
                  freqs=0,
                  station=0,
                  sr=100e3,
                  freq_dur=4):

    """
    save all relevant information that will allow an ionogram
    and range-Doppler spectra to be calculated
    """
    # 32 bit complex
    z_re=n.array(n.real(z_all), dtype=n.float16)
    z_im=n.array(n.imag(z_all), dtype=n.float16)
    print("saving raw complex voltage %s" % (fname))
    with h5py.File(fname, "w") as ho:
        ho["z_re"]=z_re
        ho["t0"]=t0
        ho["z_im"]=z_im
        ho["freqs"]=freqs
        ho["freq_dur"]=freq_dur
        ho["sample_rate"]=sr
        ho["station_id"]=station


def delete_old_files(t0, data_path="/dev/shm"):
    """
    Deleting files that are from the currently analyzed sweep or older.
    """
    # delete older files
    fl=glob.glob("%s/raw*.bin" % (data_path))
    fl.sort()
    for f in fl:
        try:
            tfile=int(re.search(".*/raw-(.*)-....bin", f).group(1))
            if tfile <= t0:
                os.system("rm %s" % (f))
        except Exception as e:
            print("error deleting file")


def analyze_latest_sweep(ic, data_path="/dev/shm"):
    """
    Analyze an ionogram, make some plots, save some data
    """
    # TODO: save raw voltage to file,
    # then analyze raw voltage file with common program
    # figure out what cycle is ready
    s=ic.s
    n_rg=ic.n_range_gates
    t0=n.uint64(n.floor(time.time()/(s.sweep_len_s))*ic.s.sweep_len_s-ic.s.sweep_len_s)
    # t0=1710445920
    sfreqs=n.array(ic.s.freqs)
    iono_freqs=sfreqs[:, 0]
    fmax=n.max(iono_freqs)
    #
    #plot_df=0.1
    plot_df=0.2

    n_plot_freqs=int((fmax+0.5)/plot_df)
    iono_p_freq=n.arange(n_plot_freqs)*plot_df  # n.linspace(0,fmax+0.5,num=n_plot_freqs)
    I=n.zeros([n_plot_freqs, n_rg], dtype=n.float32)
    IS=n.zeros([sfreqs.shape[0], n_rg], dtype=n.float32)

    # number of transmit "pulses"
    # n_t=int(ic.s.freq_dur*1000000/(ic.code_len*ic.dec))
    n_t=int(ic.s.freq_dur*2000000/(ic.code_len*ic.dec))

    all_spec=n.zeros([ic.s.n_freqs, n_t, n_rg], dtype=n.float32)

    # IPP length
    # dt=ic.dec*ic.code_len/1e6
    dt=ic.dec*ic.code_len/2e6

    # range step
    # dr = ic.dec*c.c/ic.sample_rate/2.0/1e3
    dr = ic.dec*c.c/ic.sample_rate/2.0/2e3
    
    rvec=n.arange(float(n_rg))*dr
    p_rvec=n.arange(float(n_rg)+1)*dr
    fvec=n.fft.fftshift(n.fft.fftfreq(n_t, d=dt))

    hdname=stuffr.unix2iso8601_dirname(t0, ic)
    dname="%s/%s" % (ic.ionogram_path, hdname)
    os.system("mkdir -p %s" % (dname))
    print("----------------------------------------------------")
    print("        Number of TX Pulses, n_t:", n_t)
    print("   Inter Pulse Period Length, dt:", dt)
    print("                  Range Step, dr:", dr)
    print("     Number of Range Gates, n_rg:", n_rg)
    print("      Duration of each frequency: {}".format(ic.s.freq_dur))
    print("----------------------------------------------------")
    
    
    z_all=n.zeros([ic.s.n_freqs, int(ic.s.freq_dur*100000)], dtype=n.complex64)

    noise_floors=[]

    for i in range(ic.s.n_freqs):
        print("----------------------------------------------------")
        print("   Freq IDX:", i)
        print("  Freq[MHz]:", ic.s.freqs[i])
        fname="%s/raw-%d-%03d.bin" % (data_path, t0, i)
        
        if os.path.exists(fname):
            z=n.fromfile(fname, dtype=n.complex64)
            z_all[i, :]=z
            N=len(z)
            code_idx=ic.s.code_idx(i)
            print("Num Samples:", N)
            if ic.spectral_whitening:
                # reduce receiver noise due to narrow band
                # broadcast signals by trying to filter them out
                if ic.pulse_lengths[code_idx] > 0:
                    z = p.spectral_filter_pulse(z,
                                                ipp=ic.ipps[code_idx],
                                                pulse_len=ic.pulse_lengths[code_idx])

            res=p.analyze_prc2(z,
                               code=ic.orig_codes[code_idx],
                               cache_idx=code_idx+1000000*ic.station_id,
                               rfi_rem=ic.rfi_rem,
                               spec_rfi_rem=ic.spec_rfi_rem,
                               n_ranges=n_rg, 
                               gc_rem=ic.gc_rem,
                               gc=ic.gc,
                               fft_filter=ic.fft_filter,
                               cw_rem=ic.cw_rem,
                               blank=0)

            plt.figure(figsize=(1.5*8, 1.5*6))
            plt.rc('font', size=10)
            plt.rc('axes', titlesize=15)
            plt.subplot(121)

            tvec=n.arange(int(N/ic.code_len), dtype=n.float64)*dt
            p_tvec=n.arange(int(N/ic.code_len)+1, dtype=n.float64)*dt
            with n.errstate(divide='ignore'):
                dBr=10.0*n.log10(n.transpose(n.abs(res["res"])**2.0))
            noise_floor=n.nanmedian(dBr)
            noise_floor_0=noise_floor
            noise_floors.append(noise_floor_0)
            dBr=dBr-noise_floor
            dB_max=n.nanmax(dBr)
            plt.pcolormesh(p_tvec, p_rvec-ic.range_shift*dr, dBr, vmin=-30, vmax=ic.max_plot_dB, cmap='jet')
            # plt.pcolormesh(p_tvec, p_rvec-ic.range_shift*dr, dBr, vmin=-30, vmax=dB_max, cmap='jet')
            plt.xlabel("Time (s)")
            plt.title("Range-Time Power f=%d (dB)\nnoise_floor=%1.2f (dB) peak SNR=%1.2f"
                      % (i, noise_floor, dB_max))
            plt.ylabel("Range (km)")
            plt.ylim([-10, ic.max_plot_range])

            plt.colorbar()
            plt.subplot(122)
#            S=n.abs(res["spec"])**2.0
            S=res["spec_snr"]
            print("S", S)

            #sw=n.fft.fft(n.repeat(1.0/4,4),S.shape[0])
            #for rg_id in range(S.shape[1]):
            #    S[:,rg_id]=n.roll(n.real(n.fft.ifft(n.fft.fft(S[:,rg_id])*sw)),-2)

            all_spec[i, :, :]=S
            # 100 kHz steps for ionogram freqs
            print(iono_freqs[i])#, iono_p_freq)
            pif=n.argmin(n.abs(iono_freqs[i]-iono_p_freq))
#            pif=int(iono_freqs[i]/0.1)
            print("pif", pif)

            # collect peak SNR across all doppler frequencies
            I[pif, :]+=n.max(S, axis=0)
            # print("I")
            # print(I)
            IS[i, :]=n.max(S, axis=0)

            # SNR in dB scale
            with n.errstate(divide='ignore'):
                dBs=10.0*n.log10(n.transpose(S))
            #print("dBs", dBs)
            noise_floor=n.nanmedian(dBs)
            max_dB=n.nanmax(dBs)
            plt.pcolormesh(fvec, rvec-ic.range_shift*dr, dBs, vmin=0, vmax=ic.max_plot_dB, cmap='jet')
            # plt.pcolormesh(fvec, rvec-ic.range_shift*dr, dBs, vmin=0, vmax=max_dB, cmap='jet')
            plt.ylim([-10, ic.max_plot_range])

            plt.title("Range-Doppler Power (dB)\nnoise_floor=%1.2f (dB) peak SNR=%1.2f (dB)"
                      % (noise_floor, max_dB))
            plt.xlabel("Frequency (Hz)")
            plt.ylabel("Virtual range (km)")

            cb=plt.colorbar()
            cb.set_label("SNR (dB)")
            plt.tight_layout()

            plt.savefig("%s/iono-%03d.png" % (dname, i))
            plt.close()
            plt.clf()
        else:
            return(0)
            print("file %s not found" % (fname))
        print("----------------------------------------------------")
        # sys.exit()

    i_fvec=n.zeros(ic.s.n_freqs)
    for fi in range(ic.s.n_freqs):
        i_fvec[fi]=s.freq(fi)
    with n.errstate(divide='ignore'):
        dB=10.0*n.log10(n.transpose(I))
        print("dB")
        print(dB)
    dB[n.isinf(dB)]=n.nan
    noise_floor=n.nanmedian(dB)

    for i in range(dB.shape[1]):
        dB[:, i]=dB[:, i]-n.nanmedian(dB[:, i])

    dB[n.isnan(dB)]=-3
    print("dB Again")
    print(dB)
    print(len(dB))
    # print(max(dB))

    noise_floor_0=n.mean(n.array(noise_floors))

    plt.figure(figsize=(1.5*8, 1.5*6))
    max_dB=n.nanmax(dB)
    # plt.pcolormesh(n.concatenate((iono_p_freq, [fmax+0.2])),
    #                rvec-ic.range_shift*1.5, dB, vmin=0, vmax=ic.max_plot_dB)
    plt.pcolormesh(iono_p_freq,
                   rvec-ic.range_shift*1.5, dB, vmin=0, vmax=ic.max_plot_dB, cmap=ic.color_map)
    # plt.pcolormesh(iono_p_freq,
    #                rvec-ic.range_shift*1.5, dB, vmin=0, vmax=max_dB, cmap=ic.color_map)
    
    plt.title("%s %s UT\nnoise_floor=%1.2f (dB) peak SNR=%1.2f"
              % (ic.instrument_name, stuffr.unix2datestr(t0), noise_floor_0, max_dB))
    info  = ""
    info += "TX amp    = {:3.2f}\n".format(ic.transmit_amplitude)
    info += "Dwell [s] = {:3.1f}\n".format(ic.frequency_duration)
    info += "BW [kHz]  = {:3.3f}\n".format(ic.bws[0]/1e3)
    info += "Code Type = {:s}\n".format(ic.code_types[0])
    info += "Code Len  = {:d}\n".format(ic.code_len)
    info += "IPP       = {:d}\n".format(int(ic.ipps[0]))
    info += "IPP (ms)  = {:3.3f}\n".format(float(int(ic.ipps[0])*ic.dec/ic.sample_rate)*1e3)
    info += "# of IPPs = {:d}".format(int(ic.code_len/int(ic.ipps[0])))
    if 'prn' or 'mseq' in ic.code_types[0]:
        if int(ic.pulse_lengths[0]) < 0:
            pass
        else:
            info += "\nPulse Len = {:d}".format(int(ic.pulse_lengths[0]))
            info += "\nPulse Len (ms) = {:3.3f}".format(float(int(ic.pulse_lengths[0])*ic.dec/ic.sample_rate)*1e3)
    if ic.rx_subdev == "A:A":
        info += "\nAntenna   = N/S"
    elif ic.rx_subdev == "A:B":
        info += "\nAntenna   = E/W"
    info += "\n     FFT Filter: {:s}".format(str(ic.fft_filter))
    info += "\n      CW Remove: {:s}".format(str(ic.cw_rem))
    info += "\n     RFI Remove: {:s}".format(str(ic.rfi_rem))
    info += "\nSpec RFI Remove: {:s}".format(str(ic.spec_rfi_rem))

    ax = plt.gca()
    props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    plt.text(0.05, 0.65, info, transform=ax.transAxes, fontsize=10,
            verticalalignment='bottom', horizontalalignment='left',
            bbox=props, fontfamily='monospace')


    plt.xlabel("Frequency (MHz)")
    plt.ylabel("Virtual range (km)")
    #plt.colorbar()
    cb=plt.colorbar()
    cb.set_label("SNR (dB)")

    plt.ylim([-10, ic.max_plot_range])
    plt.xlim([n.min(iono_freqs)-0.5, n.max(iono_freqs)+0.5])
    plt.tight_layout()

    datestr=stuffr.unix2iso8601(t0)
    ofname="%s/%s.png" % (dname, datestr.replace(':','.'))
    print("Saving ionogram %s" % (ofname))
    plt.savefig(ofname)
    plt.clf()
    plt.close()
    # make link to latest plot
    os.system("ln -sf %s latest.png" % (ofname))

    ofname="%s/raw-%s.h5" % (dname, datestr.replace(':','.'))
    if ic.save_raw_voltage:
        save_raw_data(ofname,
                      t0,
                      z_all,
                      ic.s.freqs,
                      ic.station_id,
                      sr=ic.sample_rate/ic.dec,
                      freq_dur=ic.s.freq_dur)

    iono_ofname="%s/ionogram-%s.h5" % (dname, datestr.replace(':','.'))
    print("Saving ionogram %s" % (iono_ofname))
    with h5py.File(iono_ofname, "w") as ho:
        ho["I"]=IS
        ho["I_rvec"]=rvec
        ho["t0"]=t0
        ho["lat"]=ic.lat
        ho["lon"]=ic.lon
        ho["I_fvec"]=sfreqs
        ho["ionogram_version"]=1

    # keep two sweeps in ringbuffer to allow oblique analysis to also finish
    delete_old_files(t0-ic.s.sweep_len_s*2)
    os.system("ln -sf %s/%s.png %s/latest.png" % (hdname, datestr.replace(':','.'), ic.ionogram_path))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-c', '--config',
        default="config/default.ini",
        help='''Configuration file. (default: %(default)s)''',
    )
    op = parser.parse_args()

    # don't create waveform files.
    ic = iono_config.get_config(config=op.config, write_waveforms=True)
    print("Starting analysis %s" % (datetime.fromtimestamp(time.time()).strftime("%FT%T")))
    analyze_latest_sweep(ic)
