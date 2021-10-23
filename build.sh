docker stop hive
docker rm hive
docker build -t gentijo/hive .
echo docker run -it -p 10000:10000 --name hive gentijo/hive
