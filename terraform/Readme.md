### commande pour demarer toutes les instances : 
``` bash  
gcloud compute instances start $(gcloud compute instances list --filter="status=TERMINATED" --format="value(name)") --zone=us-central1-a --project=$PROJECT_ID
```