# Binary Neural Net Design Contest

## Introduction

- We will be creating an FPGA accelerator for **Binary Neural Nets** (BNN)
  - Specifically, a fully connected BNN for classification
  - Design should ideally work for any topology, but will be evaluated for specific topology for digit recognition
    - Classifies input images into 0-9 categories (handwritten)
  - NO CONVOLUTION
- You are provided with:
  - Testbench + reference model (behavioral, not synthesizable)
  - DUT interface + configuration parameters
  - see [BNN_FCC_Repo](https://github.com/greg-stitt-uf/bnn_fcc_contest)
- You will:
  - Implement the DUT so that the testbench passes
  - Optimize the DUT for a specific use case
  
## Use Cases

- Two use cases:
  - Minimize Latency at the cost of throughput
  - Maximize throughput at the cost of latency
- Constraints:
  - Resources
    - Both use cases will have some resource constraints, will likely require a specific FPGA
  - Clock
    - Might be required to achieve some minimum clock frequency()
- Maximum throughput limited by bandwidth of input bus
  - It takes minimum 98 cycles to load a new image
    - If you generate faster than that, you can increase input bus width (64 by default)
    - Or, you can also optimize for latency after achieving this maximum throughput for the 64-bit bus
    - Or, you can focus on maximizing clock frequency for the 64-bit bus
  - If you want to target a different use case, you can ask for permission

## Background

- Multi-layer perceptron (MLP)
  - Form of artificial neuron net (ANN)
- Consists of:
  - Input layer (some number of inputs)
  - One or more "hidden" layers
    - All inputs provided by previous layer to each neuron in current layer (i.e. fully)
    - Each neuron generates an output that is fed to the next layer
  - Output layer
    - Similar to hidden layers but modified to generate application-specific output
    - Binary classification: 1 bit
    - **Multi-class classifciation: clog2(# of classes) bits**
    - Regression: bits depend on precision of output, usually a real value

### Neurons

- Image: look at Neuron.png
- Funtionality:
  - **Input (x)** and **weight (w)** are pairs multiplied and added together with a **bias (b)**
    - weights and biases come from training the neural net (done for us)
  - Activation funtion provides **neuron output (y)**

### MLP Topology

- MLP "topology" defined by number of inputs, number of layers, number of neurons in eahc layer
  - Input layer isn't shown or included in number of layer (sometimes)
  - WE will use the following notation: 2 -> 4 -> 2
  - Look at **MLP_Topology.png**

## Project Toplogy

- We'll be using the "SFC" (small, fully connected) topology from the FINN paper: FINN: A Framework for Fast, Scalable Binarized Neural Network Inference
- Application is 0-9 digit recognition
  - We'll train a model for the SFC topology using the MNIST dataset
  - [MNIST Dataset](https://www.tensorflow.org/datasets/catalog/mnist)
  - Classifies images as digits 0-9

## Why BNNs?

- Let's initially assume this 784 -> 256 -> 256 -> 10 toplogy uses the neurons shown earlier
  - Each neuron in the first hidden layer performs 784 multiplications
  - Ech neuron in the second hidden layer and output layer performs 256 multiplications
  - Total multiplications = 784 x 256 + 256 x 256 + 256 x 10 = 268,800
- MLPs are computationally expensive
  - this is for a small topology
- Optimization strategy: quantization
  - Reduce precision of computation (e.g. 32-bit float for 16-bit fixed)
    - placeholder text here
- What if we reduce the precision down to a single bit?
  - Every weight and input is a single bit
  - AKA: a "binary" neural net
- The entire mult -> add -> actiavtion can be replaced with:
  - xnor -> "popcount" -> threshold comparison
  - Multipliers replaced with xnor
  - Add tree replaced with population count
    - counts number of bits asserted after xnor
    - "count ones" / "Hamming weight"
  - Activation replaced with: popcount >= threshold
- Not mathematically expensive
  - heavily optimized for FPGAs

## MLP Neuron vs BNN Neuron

- Image: look at MLP_BNN.png
- x_i xnor w_i is the same as x_i == w_i
- Popcount counts # of mateches between inputs and weights
- Neuron "fires" (outputs 1) if the # of matches reach threshold

## Neuron Processor (NP) Architecture

- NP accepts P_w weights/inputs per cycle
  - P_w: parallel weights/inputs
  - If neuron's inputs/weights N <= P_w, NP requires only one pass
  - For N > P_w, accumulate the popcounts of each iteration
  - Total number of iterations = ceil(N / P_w)
    - N = 128, P_w = 16, each NP requires 8 iterations to complete a neuron
- Important: pipelining options and valid logic not shown
- Basic Building Block of an Entire BNN
  - BNN Simply Replicates NP and steers data to each instance
  - Data movement is significant challenge
    - Look at BNN_Base.png
- Significant Optimization Potential for different use cases
  - Can be easily pipelined
  - Can specialize popcount and xnor for different P_w
- What happens if N is n0ot a multiple of P_w?
  - Processor has to receive multiples of P_w
- Cheapest option: round up and pad
  - e.g. N = 12, P_w = 8, round N up to 16 with 4 padded weights
  - Pad extra weights and inputs in a way that doesn't affect output
  - For non-binary neural nets, padding weights with 0 would work because of multiplication by 0
    - But, BNN doesn't perform multiplication
  - Binary Neuron
    - counting matches between weights and inputs
  - If we pad the weights to ensure differences with the input, it will not affect the popcount
    - use 1s to pad weights and use 0s to pad inputs
  - Other options: masking
    - Add masks that causes popcount to ignore padded bits
      - much more expensive

## Translating Problem to BNN

- Input is 8-bit pixels, must be "binarized" to BNN
  - We'll use a simple threshold:
    - If pixel >= 128 then input is 1 else 0
- Output Layer needs special treatment
  - If binarized, the BNN woud simply output 10 bits (one for each digit)
  - Problem: unless only one output is asserted (unlikely), no way to identify most probable digit
- Solution: output layer skips the thresholding comparison, outputs popcount value
  - Additiona logic (argmax) chooses output based on neuron with maximum popcount
  - i.e. output layer outputs counts, argmax returns the output with the maximum value
  - LOOK at Overall_BNN_Structure.png

## DUT (bnn_fcc) Interface

- DUT: bnn_fcc (binary neural net, fully connected classifier)
- Three Main Ports, all AXI4 streaming interfaces
- Configuration Port:
  - Streams weights & thresholds for every neuron in every layer
  - Bus width is configurable, but set to 64 in the TB
  - **Config stream provided before any image inputs**
- Input Port:
  - Streams 8-bit pixels over configurable-width bus (defaults to 64 bits)
  - Stream starts after configuration complete
- Output Port:
  - DUT provides stream of 8-bit classification outputs
  - Actual 4-bit outputs must be expanded to 8-bits due to AXI byte-aligned requirement
- Look at BNN_Port.png

## Configuration Format

- The config port streams in all weights and thresholds
  - Messages are specific to a layer
    - Config stream provides 2 messages per layer (one for weights, one for thresholds)
  - Provided in format that imitates network communication
- Configuration Header (1st 128-bits of message stream)
  - Look at Configuration_Header.png
- Payload immediately follows configuration header
  - Length in bytes are specified by total_bytes in header
- For weights (msg_type = 0), payload packs weights for each neuron in the layer in consecutive order
  - Neuron weights are byte-aligned to simplify parsing
  - Requires padding if neuron weights aren'ts multiple of 8
  - Unused bits padded with 1s to avoid affecting popcount
- Simple example: (10 weights per neuron):
  - Look at Simple_Example.png
- For thresholds (msg_type=1), payload packs 32-bit thresholds fore each neuron in the layer in consecutive order
  - Simple Example 2: Look at Simple_Example_2.png

## Memory Architecture and Data Layout
  
### Data Layout

- Where to store data after parsing it?
  - You will need to design your own custom memory architecture
    - Figure out data layout (how to organize data across arch)
  - Ex:
    - 1 Large Block RAM: simple, but restricts parallelism
    - Separate Block RAM for each neuron processor: store weights for all neurons that will be exectured on that processor across all layers
    - Separate Block RAM for each neuron processor in each layer
    - Separate Block RAMs for weights and thresholds
      - Probably a good idea to simplify addressing logic
      - most parallelism
  - "Configuration Manager" will parse data from stream and store it in approproate location

### Overall Architecture

- Look at Overall_Arch.png
- Look at Overall_Arch2.png
- In general, number of neurons in layer will exeed P_N
  - Processors will be shared across multiple actual neurons
  - e.g. 16 total neurons in layer, 2 neuron processors
  - Processor 0 handles neurons 0, 2, 4, 6, 8, etc.
  - Processor 1 handles neurons 1, 3, 5, 7, 9, etc.
- Configuration Manager must take this into consideration wehn sorting weights/thresholds

## Parallelization Strategies

- One layer at a time
  - prioritizes latency of each individual layer at cost of throughput
- Multiple layers at a time
  - Each layer takes longer, but better throughput
- All layers in parallel
  - Each layer is slow, but throughput is likely best
  - Throughput limited ot latency of slowest layer, which might suffer from fewer allocated resources
- Use same P_N and P_W for all layers?
  - Greatly simplifies configuration manager
  - But, restricts parallelism
    - E.g. might want higher P_w for first hidden layer, which has many input (784 vs. 256)
- Recommendation: start simple, maybe even P_N = 1 and P_W = 1
  - Get it working, then increase parallelism and parameterize
  - Or, set P_N = P_W = 8 to initially eliminate all width conversion challenges
