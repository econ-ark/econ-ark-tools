# Based on https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Mridul Seth <seth.mridul@gmail.com>"

USER $NB_UID

# packages required on top of scipy-notebook docker stack.
RUN conda install --quiet --yes \
    'econ-ark' \
    && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


