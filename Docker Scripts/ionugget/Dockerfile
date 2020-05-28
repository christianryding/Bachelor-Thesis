FROM python:3.7
COPY ionugget.py /ionugget.py
RUN mkdir -p /var/result
VOLUME /var/result
CMD ["python" ,"/ionugget.py", "-o/var/result"]
