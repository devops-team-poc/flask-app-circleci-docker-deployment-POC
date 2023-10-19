FROM python:3.10
ADD Flask_application.py .
RUN pip install Flask
ENV FLASK_APP=Flask_application.py
EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
