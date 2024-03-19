# from langchain_community.llms import LlamaCpp
from tabulate import tabulate
from langchain_openai import ChatOpenAI
from langchain_community.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import SimpleSequentialChain
import time

def insert_newlines(text, interval=30):
    return '\n'.join(text[i:i+interval] for i in range(0, len(text), interval))

# Define the prompt template
design_prompt = """You are a network engineer tasked with designing a 3-building campus network using the most recent Cisco equipment. Please provide a detailed design specification, including:
1. Network topology ascii diagram
2. List of required hardware (routers, switches, firewalls, etc.). Include Product IDs for ordering.
3. List of software image to use for each product.
4. IP addressing scheme
5. VLAN configuration
6. Routing protocols
7. Security considerations
Your design should prioritize performance, scalability, and security. Label each section of your response with the corresponding title."""

grading_prompt_template = """You are a network engineering expert tasked with judging a network design for a 3-building campus network using the most recent Cisco equipment. The design requirements were:

{design_prompt}

Here is the output:

{output}

Your job is to provide a ranking of the answer from 1 to 10 with 1 being the worst and 10 the best. Be strict in your grading. Then provide a short summary of the evaluation in 80 characters or less. Then provide more detailed comments about the design, based on how well it meets the requirements but also based on how easily a network engineer would be able to install and configure the network. Also comment on how the design requirements could be improved to provide more useful network design.
"""

models = [
    Ollama(model="dolphin-phi"),
    Ollama(model="orca-mini"),
    Ollama(model="phi"),
    Ollama(model="gemma:2b"),
    Ollama(model="llama2:7b"),
    # Ollama(model="llama2:13b"),
    # Ollama(model="llama2:70b"),
]

model_params = {
    "dolphin-phi": "2.7b",
    "orca-mini": "3b",
    "phi": "2.7b",
    "gemma:2b": "3b",
    "llama2:7b": "9b",
    "llama2:13b": "13b"
}

# Create the prompt and chain
design_prompt_template = PromptTemplate(template=design_prompt, input_variables=[])
grading_prompt_template = PromptTemplate(template=grading_prompt_template, input_variables=["output"])

# Create the chains
grading_model = ChatOpenAI(model="gpt-3.5-turbo")

# Benchmark the models
results = []
for model in models:
    model_name = model.model
    model_filename = str(model.__repr__()).translate(str.maketrans("(),=':", "______"))
    print(f"\n\nPre-loading model: {model_name}")
    model.invoke("")
    print(f"Running model: {model_name}")
    design_chain = design_prompt_template | model
    start_time = time.time()
    output = design_chain.invoke({})
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Finished in {elapsed_time} seconds")
    print(f"Grading {model_name}'s design")

    # Prompt the grading LLM
    grading_prompt = grading_prompt_template.format(design_prompt=design_prompt, output=output)
    grade_output = grading_model.invoke(grading_prompt)
    grade_content = grade_output.content
    print(f"Grade is {grade_content}")

    with open(f"buds_results/{model_filename}.txt", "w") as file:
        file.write(f"{model_name}\n\n")
        file.write(f"{elapsed_time}\n\n")
        file.write(f"{output}\n\n")
        file.write(f"{grade_content}\n\n")

    grade = grade_content.split("\n")[0].strip()
    summary = grade_content.split("Summary: ")[1].split("\n")[0].strip()
    comments = grade_content.split("Comments:")[1].strip()

    results.append([model_name, elapsed_time, model_params[model_name], grade, insert_newlines(summary, 40)])

# Print table
headers = ["Model", "Time", "Params", "Grade", "Summary"]
print(tabulate(results, headers=headers, tablefmt="fancy_grid"))
