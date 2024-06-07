FROM python:alpine3.19   
WORKDIR /app
COPY app.py .
EXPOSE 5000
ENTRYPOINT ["python", "app.py"]




