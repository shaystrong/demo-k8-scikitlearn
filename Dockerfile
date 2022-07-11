FROM jupyter/scipy-notebook

COPY train.py ./train.py
RUN python3 train.py
