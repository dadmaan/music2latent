# Use NVIDIA CUDA base image for GPU support
FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-devel

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*


# Install Jupyter Notebook
RUN pip install jupyter

# Clone the music2latent repository
RUN git clone https://github.com/dadmaan/music2latent.git /app/music2latent

WORKDIR /app/music2latent

# install Python dependencies
RUN pip install --no-cache-dir -e .
RUN pip install --no-cache-dir -r music2latent/requirements.txt

# To run jupyter in remote development scenario with VSCode
# from https://stackoverflow.com/questions/63998873/vscode-how-to-run-a-jupyter-notebook-in-a-docker-container-over-a-remote-serve
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# Expose port for Jupyter Notebook
EXPOSE 8888

# Use Tini as the container's entry point
ENTRYPOINT ["/usr/bin/tini", "--"]

# Command to run Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]