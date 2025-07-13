# ACELP Codec for Industrial Radio Communication: FPGA Implementation
25,6 kbps pseudo-ACELP voice codec with dynamically generated code books, adapted for eastern slavic languages

## Project Overview
- **Bitrate**: 25,6 kbps
- **Sampling**: 16 kHz; 16-bit PCM
- **Target FPGA**: Altera Cyclone V `5CEBA2F17C8N`
- **Key Features**:
  - Optimized for East Slavic languages (Russian, Ukrainian, Belarusian)
  - Frame loss concealment (PLC) for ≥3 consecutive frames
  - Fixed-point arithmetic (Q15 format)
  - Dynamically generated codebooks (no pre-loaded tables)
  - Parallel processing for critical paths

## Verilog Module Hierarchy (Bottom-Up)

### Level 0: Base Components (Independent)
- `frame_buffer.v`: 480-sample frame buffer (30 ms)
- `acb_buffer.v`: Adaptive codebook buffer
- `fcb_buffer.v`: Fixed codebook buffer
- `generate_lsp_codebooks.v`: LSP codebook generator
- `design_biased_codebook.v`: Biased FCB generator

### Level 1: Signal Processing & Utilities
- `preprocess.v`: HPF (70 Hz) and pre-emphasis
- `postprocess.v`: De-emphasis
- `detect_transitions.v`: Transient detector
- `energy_bands.v`: Energy band analyzer
- `classify_signal.v`: Signal classifier (vowel/consonant)

### Level 2: Parameter Analysis & Conversion
- `lpc_analysis.v`: 16th-order LPC analysis
- `lpc_to_lsp.v`: LPC → LSP conversion
- `lsp_quantize.v`: LSP quantization (P-MSVQ, 54 bits)
- `lsp_unquantize.v`: LSP reconstruction

### Level 3: Excitation Generation
- `generate_excitation.v`: ACB+FCB excitation synthesis
- `vq_encode_fcb.v`: FCB vector quantization (158 bits/subframe)

### Level 4: Parameter Search
- `acb_search.v`: Adaptive codebook (pitch) search
- `fcb_search.v`: Algebraic codebook search

### Level 5: Frame Packing
- `stability_params.v`: Stability parameter calculation (81 bits)
- `pack_bitstream.v`: Frame assembly (768 bits)
- `unpack_bitstream.v`: Frame disassembly

### Level 6: Synthesis & Error Handling
- `speech_synthesis.v`: LPC speech synthesis
- `plc_concealment.v`: Packet loss concealment

### Level 7: State Initialization
- `init_encoder_state.v`: Encoder state init
- `init_decoder_state.v`: Decoder state init

### Level 8: Core Codec Blocks
- `acelp_encoder.v`: Full encoder
- `acelp_decoder.v`: Full decoder

### Level 9: Top-Level Integration
- `acelp_codec_top.v`: System integration (encoder+decoder)

## Implementation Order
1. **Level 0**: Buffers and codebook generators
2. **Level 1**: Preprocessing and utility modules
3. **Level 2**: LPC analysis and LSP conversion
4. **Level 3**: Excitation generation
5. **Level 4**: ACB/FCB search algorithms
6. **Level 5**: Bitstream packing and stability params
7. **Level 6**: Synthesis and PLC
8. **Level 7+**: Integration and top-level

## Key Implementation Notes
- **Fixed-Point**: All audio data in Q15 format (`signed [15:0]`)
- **Reset**: Asynchronous active-low reset (`rst_n`)
- **Clock**: Single 50 MHz clock (`clk`)
- **Interfaces**: Parallel buses only (no serial interfaces)
- **FPGA Resources**:
  - Logic Elements: ~15-20k (24,6k available)
  - Memory: <18,3 Kb (1,134 Kb available)
  - DSP Blocks: ~40-50 (66 available)

## Resource Optimization Techniques
1. **Fixed-Point Arithmetic**: Q15 format throughout
2. **Parallel Processing**:
   - FCB search: 5 tracks processed concurrently
   - LSP quantization: 3-stage pipeline
3. **Memory Optimization**:
   - Use M9K blocks for buffers
   - Dynamic codebook generation (no ROM storage)
4. **Algorithmic Optimizations**:
   - Subsample pitch search
   - Focused FCB search
   - Vectorized DSP instructions

## Next Steps
1. Implement and verify Level 0 modules
2. Develop testbenches for each module
3. Integrate modules incrementally
4. Perform timing analysis
5. Test with real East Slavic language samples