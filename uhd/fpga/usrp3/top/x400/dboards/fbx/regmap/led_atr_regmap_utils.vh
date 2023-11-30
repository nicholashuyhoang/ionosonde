//
// Copyright 2023 Ettus Research, A National Instruments Company
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//
// Module: led_atr_regmap_utils.vh
// Description:
// The constants in this file are autogenerated by XmlParse.

//===============================================================================
// A numerically ordered list of registers and their HDL source files
//===============================================================================

  // LED0_ATR_STATE          : 0x0 (led_atr_control.v)
  // LED1_ATR_STATE          : 0x400 (led_atr_control.v)
  // LED2_ATR_STATE          : 0x800 (led_atr_control.v)
  // LED3_ATR_STATE          : 0xC00 (led_atr_control.v)
  // LED_ATR_OPTION_REGISTER : 0x1000 (led_atr_control.v)
  // LED_ATR_DISABLED        : 0x1004 (led_atr_control.v)

//===============================================================================
// RegTypes
//===============================================================================

  // LED_ATR_STATE Type (from led_atr_control.v)
  localparam LED_ATR_STATE_SIZE = 32;
  localparam LED_ATR_STATE_MASK = 32'h7;
  localparam RX2_LED_SIZE = 1;  //LED_ATR_STATE:RX2_LED
  localparam RX2_LED_MSB  = 0;  //LED_ATR_STATE:RX2_LED
  localparam RX2_LED      = 0;  //LED_ATR_STATE:RX2_LED
  localparam TXRX_RED_LED_SIZE = 1;  //LED_ATR_STATE:TXRX_RED_LED
  localparam TXRX_RED_LED_MSB  = 1;  //LED_ATR_STATE:TXRX_RED_LED
  localparam TXRX_RED_LED      = 1;  //LED_ATR_STATE:TXRX_RED_LED
  localparam TXRX_GR_LED_SIZE = 1;  //LED_ATR_STATE:TXRX_GR_LED
  localparam TXRX_GR_LED_MSB  = 2;  //LED_ATR_STATE:TXRX_GR_LED
  localparam TXRX_GR_LED      = 2;  //LED_ATR_STATE:TXRX_GR_LED

//===============================================================================
// Register Group LED_ATR_REGISTERS
//===============================================================================

  // Enumerated type LED_SIZE_TYPE
  localparam LED_SIZE_TYPE_SIZE = 1;
  localparam LED_SIZE  = 'h3;  // LED_SIZE_TYPE:LED_SIZE

  // LED0_ATR_STATE Register (from led_atr_control.v)
  localparam LED0_ATR_STATE_COUNT = 256; // Number of elements in array

  // LED1_ATR_STATE Register (from led_atr_control.v)
  localparam LED1_ATR_STATE_COUNT = 256; // Number of elements in array

  // LED2_ATR_STATE Register (from led_atr_control.v)
  localparam LED2_ATR_STATE_COUNT = 256; // Number of elements in array

  // LED3_ATR_STATE Register (from led_atr_control.v)
  localparam LED3_ATR_STATE_COUNT = 256; // Number of elements in array

  // LED_ATR_OPTION_REGISTER Register (from led_atr_control.v)
  localparam LED_ATR_OPTION_REGISTER = 'h1000; // Register Offset
  localparam LED_ATR_OPTION_REGISTER_SIZE = 32;  // register width in bits
  localparam LED_ATR_OPTION_REGISTER_MASK = 32'hF;
  localparam LED0_ATR_OPTION_SIZE = 1;  //LED_ATR_OPTION_REGISTER:LED0_ATR_OPTION
  localparam LED0_ATR_OPTION_MSB  = 0;  //LED_ATR_OPTION_REGISTER:LED0_ATR_OPTION
  localparam LED0_ATR_OPTION      = 0;  //LED_ATR_OPTION_REGISTER:LED0_ATR_OPTION
  localparam LED1_ATR_OPTION_SIZE = 1;  //LED_ATR_OPTION_REGISTER:LED1_ATR_OPTION
  localparam LED1_ATR_OPTION_MSB  = 1;  //LED_ATR_OPTION_REGISTER:LED1_ATR_OPTION
  localparam LED1_ATR_OPTION      = 1;  //LED_ATR_OPTION_REGISTER:LED1_ATR_OPTION
  localparam LED2_ATR_OPTION_SIZE = 1;  //LED_ATR_OPTION_REGISTER:LED2_ATR_OPTION
  localparam LED2_ATR_OPTION_MSB  = 2;  //LED_ATR_OPTION_REGISTER:LED2_ATR_OPTION
  localparam LED2_ATR_OPTION      = 2;  //LED_ATR_OPTION_REGISTER:LED2_ATR_OPTION
  localparam LED3_ATR_OPTION_SIZE = 1;  //LED_ATR_OPTION_REGISTER:LED3_ATR_OPTION
  localparam LED3_ATR_OPTION_MSB  = 3;  //LED_ATR_OPTION_REGISTER:LED3_ATR_OPTION
  localparam LED3_ATR_OPTION      = 3;  //LED_ATR_OPTION_REGISTER:LED3_ATR_OPTION

  // LED_ATR_DISABLED Register (from led_atr_control.v)
  localparam LED_ATR_DISABLED = 'h1004; // Register Offset
  localparam LED_ATR_DISABLED_SIZE = 32;  // register width in bits
  localparam LED_ATR_DISABLED_MASK = 32'hF;
  localparam LED0_ATR_DISABLED_SIZE = 1;  //LED_ATR_DISABLED:LED0_ATR_DISABLED
  localparam LED0_ATR_DISABLED_MSB  = 0;  //LED_ATR_DISABLED:LED0_ATR_DISABLED
  localparam LED0_ATR_DISABLED      = 0;  //LED_ATR_DISABLED:LED0_ATR_DISABLED
  localparam LED1_ATR_DISABLED_SIZE = 1;  //LED_ATR_DISABLED:LED1_ATR_DISABLED
  localparam LED1_ATR_DISABLED_MSB  = 1;  //LED_ATR_DISABLED:LED1_ATR_DISABLED
  localparam LED1_ATR_DISABLED      = 1;  //LED_ATR_DISABLED:LED1_ATR_DISABLED
  localparam LED2_ATR_DISABLED_SIZE = 1;  //LED_ATR_DISABLED:LED2_ATR_DISABLED
  localparam LED2_ATR_DISABLED_MSB  = 2;  //LED_ATR_DISABLED:LED2_ATR_DISABLED
  localparam LED2_ATR_DISABLED      = 2;  //LED_ATR_DISABLED:LED2_ATR_DISABLED
  localparam LED3_ATR_DISABLED_SIZE = 1;  //LED_ATR_DISABLED:LED3_ATR_DISABLED
  localparam LED3_ATR_DISABLED_MSB  = 3;  //LED_ATR_DISABLED:LED3_ATR_DISABLED
  localparam LED3_ATR_DISABLED      = 3;  //LED_ATR_DISABLED:LED3_ATR_DISABLED

  // Return the offset of an element of register array LED0_ATR_STATE
  function integer LED0_ATR_STATE (input integer i);
    LED0_ATR_STATE = (i * 'h4) + 'h0;
  endfunction

  // Return the offset of an element of register array LED1_ATR_STATE
  function integer LED1_ATR_STATE (input integer i);
    LED1_ATR_STATE = (i * 'h4) + 'h400;
  endfunction

  // Return the offset of an element of register array LED2_ATR_STATE
  function integer LED2_ATR_STATE (input integer i);
    LED2_ATR_STATE = (i * 'h4) + 'h800;
  endfunction

  // Return the offset of an element of register array LED3_ATR_STATE
  function integer LED3_ATR_STATE (input integer i);
    LED3_ATR_STATE = (i * 'h4) + 'hC00;
  endfunction
