# Based on https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Mridul Seth <seth.mridul@gmail.com>"

USER root

# install latex-full installation
RUN apt-get update && \
    apt-get install -y --no-install-recommends texlive-full dvipng && \
    rm -rf /var/lib/apt/lists/*

USER $NB_UID
WORKDIR $HOME

# packages required on top of scipy-notebook docker stack.
# install latest release of econ-ark
RUN conda install  --yes \
    'econ-ark=0.10.7' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
