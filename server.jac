# import:py from mtllm.llms {OpenAI}
# glob llm = OpenAI(model_name='gpt-4o');
import:py from mtllm.llms {Ollama}
glob llm = Ollama(model_name='llama3.1');
import:jac from rag {RagEngine}
glob rag_engine:RagEngine = RagEngine();

# node Session {
#     has id: str;
#     has chat_history: list[dict];
#     has status: int = 1;

#     can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
#     llm_chat(
#         message:'current message':str,
#         chat_history: 'chat history':list[dict],
#         agent_role:'role of the agent responding':str,
#         context:'retrieved context from documents':list
#     ) -> 'response':str by llm();
# }

#* 1. Session Node: 
        Tracks chat history and convo state, chat interaction begins here
        and chat ability within session spawns the infer walker to handle
        dialogue routing based on the user's input. Evertime the user sends
        a message, the system will try to classify it and route it to the 
        best model which is RAG or QA
*#
node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can chat with interact entry {
        self.chat_history.append({"role": "user", "content": here.message});
        response = infer(message=here.message, chat_history=self.chat_history) spawn root;
        self.chat_history.append({"role": "assistant", "content": response.response});

        report {
            "response": response.response
        };
    }
}


#* 2. interact Walker:
        This walker handles starting the session and running the chat
        interactions. It uses the session node to store and manage 
        dialogue. Continuous chat session with history
*#
walker interact {
    has message: str;
    has session_id: str;

    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }

    can chat with Session entry {
        here.chat_history.append({"role": "user", "content": self.message});
        data = rag_engine.get_from_chroma(query=self.message);
        response = here.llm_chat(
            message=self.message,
            chat_history=here.chat_history,
            agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
            context=data
        );

        here.chat_history.append({"role": "assistant", "content": response});

        report {"response": response};
    }
}


#* 3. Enum ChatType:
        enum defines two possible states. RAG (retrieving documents)
        and QA (simple question-answering). Processes will classify the
        incoming user message and route it based on one of these two states.
*#
enum ChatType {
    RAG : 'Need to use Retrievable information in specific documents to respond' = "RAG",
    QA : 'Given context is enough for an answer' = "user_qa"
}


#* 4. Router Node:
        This node is responsible for classifying the user's message and
        determines to route it to RAG or QA based chat.
*#
node Router {
    can 'route the query to the appropriate task type'
    classify(message:'query from the user to be routed.':str) -> ChatType by llm(method="Reason", temperature=0.0);
}


#* 5. RagChat and QAChat Nodes:
        These nodes are for the chat models, each node
        has a respond ability that interacts with the
        rag_engine or with the LLM depending on type of
        query.
*#
node Chat {
    has chat_type: ChatType;
}
node RagChat :Chat: {
    has chat_type: ChatType = ChatType.RAG;

    can respond with infer entry {
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
                    chat_history: 'chat history':list[dict],
                    agent_role:'role of the agent responding':str,
                    context:'retirved context from documents':list
                        ) -> 'response':str by llm();
        data = rag_engine.get_from_chroma(query=here.message);
        here.response = respond_with_llm(here.message, here.chat_history, "You are a conversation agent designed to help users with their queries based on the documents provided", data);
    }
}
node QAChat :Chat: {
    has chat_type: ChatType = ChatType.QA;

    can respond with infer entry {
        can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
        respond_with_llm(   message:'current message':str,
            chat_history: 'chat history':list[dict],
            agent_role:'role of the agent responding':str
                ) -> 'response':str by llm();
        here.response = respond_with_llm(here.message, here.chat_history, agent_role="You are a conversation agent designed to help users with their queries");
    }
}


#* 6. infer Walker:
        It is the dialogue routing system, first initializing
        the router node and then routes the query based on the
        class (RAG or QA models)
*#
walker infer {
    has message:str;
    has chat_history: list[dict];

    can init_router with `root entry {
        visit [-->](`?Router) else {
            router_node = here ++> Router();
            router_node ++> RagChat();
            router_node ++> QAChat();
            visit router_node;
        }
    }

    can route with Router entry {
        classification = here.classify(message = self.message);
        visit [-->](`?Chat)(?chat_type==classification);
    }
}




# walker interact {
#     can return_message with `root entry {
#         report {
#             "response": "Hello, world!"
#         };
#     }
# }

# walker interact_with_body {
#     has name: str;

#     can return_message with `root entry {
#         report {
#             "response": "Hello, " + self.name + "!"
#         };
#     }
# }

