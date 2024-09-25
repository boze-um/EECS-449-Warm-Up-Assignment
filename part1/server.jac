walker interact {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker interact_with_body {
    has name: str;

    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}

# Walker 1
walker best_anime_character {
    can return_message with `root entry {
        report {
            "response": "The best anime character is Luffy from One Piece. He will be king of the pirates!"
        };
    }
}



# Walker 2
walker zelda_explanation {
    can return_message with `root entry {
        report {
            "response": "Many people confuse Zelda with the hero in green, but Zelda is the princess! The one who wears the green cap is Link."
        };
    }
}