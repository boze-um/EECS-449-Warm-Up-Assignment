# Rag + Dialogue Routing Chatbot

This project implements a Retrieval Augmented Generation (RAG) chatbot, capable of dialogue routing
using Jac Cloud and Streamlit. The chatbot retrieves information from a set of documents and generates
responses based on user queries.

## Features
- RAG: Fetches relelvant information from documents stored in a Chroma vector database
- Dialogue Routing: Routes conversations to either RAG model or a Question-Answering (QA) model based on the nature of the query.
- Session Management: Stores conversation history for ongoing dialogue between the chatbot and user.

## Prereqs
- MongoDB (Docker)
- Jac-lang
- Jac Cloud
- ChromaDB
- Streamlit
- Ollama embeddings or OpenAI API for LLM

## MongoDB Setup w/ Docker
Setup MongoDB with Docker:
```
docker pull mongodb/mongodb-community-server:latest
docker run --name mongodb -p 27017:27017 -d mongodb/mongodb-community-server:latest --replSet my-rs
```
Initiate the MongoDB:
```
mongosh --port 27017
rs.initiate({_id: "my-rs", members: [{_id: 0, host: "localhost"}]})
```


## Ollama Setup
Download the required embeddings model and serve it:
```
ollama pull llama3.1
ollama serve
```

## Installation
1. Clone the repo
2. Install dependencies
```
pip install jaclang==0.7.19 jac-cloud==0.1.1 chromadb==0.5.0 jac-streamlit==0.0.3
```
3. Create a directory docs/ and add your PDF documents into it. They will be indexed and used for retrieval-based responses.
4. Configure your MongoDB connection: In your terminal, export the following:
```
export DATABASE_HOST=mongodb://localhost:27017/?replicaSet=my-rs
```

## Running the Server
1. Start the Jac Cloud backend by running the following command:
```
DATABASE_HOST=mongodb://localhost:27017/?replicaSet=my-rs jac serve server.jac
```
2. Verify that the server is running by visiting http://localhost:8000/docs in your browser. You should see the Swagger UI for interacting with your API

## Authentication
To use the API, you'll need to register and login to get an access token:
### Register a new user:
```
curl --location 'http://localhost:8000/user/register' \
--header 'Content-Type: application/json' \
--data '{
  "password": "password",
  "email": "test@mail.com"
}'
```
### Login to get a token:
```
curl --location 'http://localhost:8000/user/login' \
--header 'Content-Type: application/json' \
--data '{
  "password": "password",
  "email": "test@mail.com"
}'
```
The response will contain an access token which you use to authenticate requests.


## Testing the Chatbot
You can use this curl command to test the chatbot:
```
curl -X POST http://localhost:8000/walker/interact -H "Authorization: Bearer <TOKEN>" \
--header 'Content-Type: application/json' \
--data '{
  "message": "Ask your question here",
  "session_id": "123"
}'
```
Replace '<TOKEN>' with your access token.
This can also be done using the Swagger UI

## Streamlit Frontend
To run the frontend interface using Streamlit, execute this in a new terminal:
```
jac streamlit client.jac
```

## Example Questions to Ask
- "What documents do you have?"
- "Help"
- "Tell me about Word2Vec from the documents"
- "What is ELMo?"