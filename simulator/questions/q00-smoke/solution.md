kubectl -n smoke create deploy hello --image=nginx:1.27 --replicas=2
echo done > ~/smoke.txt
