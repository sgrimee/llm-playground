# from langchain_community.llms import LlamaCpp
from langchain_community.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import SimpleSequentialChain
import time

# Define the prompt template
prompt_template = """
You are a network engineer tasked with designing a 3-building campus network using the most recent Cisco equipment. Please provide a detailed design specification, including:

1. Network topology ascii diagram
2. List of required hardware (routers, switches, firewalls, etc.)
3. IP addressing scheme
4. VLAN configuration
5. Routing protocols
6. Security considerations

Your design should prioritize performance, scalability, and security.
Label each section of your response with the corresponding title.
"""

models = [
    Ollama(model="llama2:7b"),
    Ollama(model="llama2:13b"),
    Ollama(model="llama2:70b"),
]

# Create the prompt and chain
prompt = PromptTemplate(template=prompt_template, input_variables=[])

# Benchmark the models
results = []
for model in models:
    print(f"Running model: {model.get_name()}")
    chain = prompt | model
    start_time = time.time()
    output = chain.invoke({})
    end_time = time.time()
    elapsed_time = end_time - start_time

    # Evaluate the network design and assign a grade
    if "diagram" in output.lower() and "hardware" in output.lower() and "ip addressing" in output.lower() and "vlan" in output.lower() and "routing" in output.lower() and "security" in output.lower():
        grade = "A"
    elif "diagram" in output.lower() and "hardware" in output.lower() and "ip addressing" in output.lower() and "vlan" in output.lower() and "routing" in output.lower():
        grade = "B"
    elif "diagram" in output.lower() and "hardware" in output.lower() and "ip addressing" in output.lower():
        grade = "C"
    else:
        grade = "F"

    results.append((model.get_name(), elapsed_time, grade, output))

# Print the results in a tabular format
print("\n{:<20} {:<20} {:<20} {:<}".format("Model", "Time (s)", "Grade", "Output"))
print("-" * 80)
for model_name, elapsed_time, grade, output in results:
    print("{:<20} {:<20} {} {}".format(model_name, round(elapsed_time, 2), grade, output[:20] + "...")) 
