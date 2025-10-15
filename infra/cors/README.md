# CORS middleware for Traefik

Allow CORS access from some common ports on localhost (for development purposes).  This allows clients at <http://localhost:5173> (Vite default port) and <http://localhost:8000> (FastAPI default port) to interact with already-deployed services on the Kubernetes cluster.

This middleware should be disabled in a production environment.
