# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # TEST 1: FAIL - stop at 5, not 10
    dut._log.info("Lose Test")
    await ClockCycles(dut.clk, 5)
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    count = int(dut.uo_out.value) & 0xF
    win = (int(dut.uo_out.value) >> 4) & 1
    assert count == 5 and win == 0, f"Lose Test: FAIL - expected count=5 win=0, got count={count} win={win}"
    dut._log.info(f"Lose Test: PASS - stopped at {count}, no win")

    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # TEST 2: WIN - stop at 10
    dut._log.info("Win Test")
    await ClockCycles(dut.clk, 9)
    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)
    count = int(dut.uo_out.value) & 0xF
    win = (int(dut.uo_out.value) >> 4) & 1
    assert count == 10 and win == 1, f"Win Test: FAIL - expected count=10 win=1, got count={count} win={win}"
    dut._log.info(f"Win Test: PASS - win at {count}")

    # TEST 3: counter holds after stop
    dut._log.info("Stop Test")
    await ClockCycles(dut.clk, 5)
    count = int(dut.uo_out.value) & 0xF
    assert count == 10, f"Stop Test: FAIL - counter kept running, count={count}"
    dut._log.info(f"Stop Test: PASS - counter held at {count}")

    # TEST 4: reset clears everything
    dut._log.info("Reset Test")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    count = int(dut.uo_out.value) & 0xF
    win = (int(dut.uo_out.value) >> 4) & 1
    assert count == 0 and win == 0, f"Reset Test: FAIL - count={count} win={win}"
    dut._log.info("Reset Test: PASS - reset cleared count and win")

    # Set the input values you want to test
    #dut.ui_in.value = 20
    #dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    #await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
