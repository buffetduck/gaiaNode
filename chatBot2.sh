#!/bin/bash

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"
    local api_url="$3"

    while true; do
        # Prepare the JSON payload
        json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
        )

        # Send the request using curl and capture both the response and status code
        response=$(curl -s -w "\n%{http_code}" -X POST "$api_url" \
            -H "Authorization: Bearer $api_key" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$json_data")

        # Extract the HTTP status code from the response
        http_status=$(echo "$response" | tail -n 1)
        body=$(echo "$response" | head -n -1)

        if [[ "$http_status" -eq 200 ]]; then
            # Check if the response is valid JSON
            echo "$body" | jq . > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                # Print the question and response content
                echo "✅ [SUCCESS] API: $api_url | Message: '$message'"

                # Extract the response message from the JSON
                response_message=$(echo "$body" | jq -r '.choices[0].message.content')
                
                # Print both the question and the response
                echo "Question: $message"
                echo "Response: $response_message"
                break  # Exit loop if request was successful
            else
                echo "⚠️ [ERROR] Invalid JSON response! API: $api_url"
                echo "Response Text: $body"
            fi
        else
            echo "⚠️ [ERROR] API: $api_url | Status: $http_status | Retrying in 2s..."
            sleep 2
        fi
    done
}

# Define a list of predefined messages
user_messages=(
  "What's the capital of France?"  
  "How many legs does a spider have?"  
  "Who wrote *Romeo and Juliet*?"  
  "What is 2 + 2?"  
  "What color is the sky on a clear day?"  
  "Which planet is known as the Red Planet?"  
  "What is the tallest animal in the world?"  
  "How many continents are there on Earth?"  
  "What do bees produce?"  
  "What's the main ingredient in a peanut butter sandwich?"  
  "Which ocean is the largest?"  
  "What is the freezing point of water in Celsius?"  
  "What is the opposite of 'hot'?"  
  "How many sides does a triangle have?"  
  "What is the name of Mickey Mouse’s pet dog?"  
  "Which country is famous for making sushi?"  
  "What sound does a cat make?"  
  "How many letters are in the English alphabet?"  
  "Who painted the Mona Lisa?"  
  "What do you call a baby dog?"  
  "Which fruit is yellow and curved?"  
  "What is H2O commonly known as?"  
  "Which holiday is celebrated on December 25th?"  
  "How many wheels does a bicycle have?"  
  "What is the main language spoken in Spain?"  
  "Which metal is liquid at room temperature?"  
  "What is the currency of the United States?"  
  "What do cows drink?"  
  "Which organ pumps blood through the body?"  
  "What is the first month of the year?"  
  "How many wings does a butterfly have?"  
  "Which gas do humans need to breathe to survive?"  
  "Who was the first person to walk on the moon?"  
  "What does a thermometer measure?"  
  "Which shape has four equal sides?"  
  "What is the capital of Italy?"  
  "What color is a stop sign?"  
  "How many days are in a week?"  
  "What is the opposite of 'day'?"  
  "Where do penguins live, the Arctic or Antarctica?"  
  "What is the name of the fairy in *Peter Pan*?"  
  "How many fingers does a human have on one hand?"  
  "Which bird is known for repeating words?"  
  "What do you call a place where books are kept?"  
  "Which animal is known as the 'King of the Jungle'?"  
  "How many hours are in a day?"  
  "Which instrument has black and white keys?"  
  "What does a caterpillar turn into?"  
  "What color are most leaves?"  
  "What is the name of the toy cowboy in *Toy Story*?"  
  "What is the opposite of 'left'?"  
  "What do you use to cut paper?"  
  "What color is a ripe strawberry?"  
  "What does 'www' stand for in a website address?"  
  "What do you call a baby sheep?"  
  "What is the capital of the United Kingdom?"  
  "What do you call the season after winter?"  
  "Which sport is played at Wimbledon?"  
  "What is the name of the planet we live on?"  
  "What do you call someone who writes books?"  
  "Which animal is known for carrying its home on its back?"  
  "What is the name of the superhero with a red cape and an 'S' on his chest?"  
  "How many toes does a human have?"  
  "Which number comes after 9?"  
  "What is the name of the big red dog in children’s books?"  
  "What do you call a baby cat?"  
  "What is the main ingredient in a salad?"  
  "What do you call a shape with five sides?"  
  "What do you wear on your feet when it’s cold?"  
  "What do plants need to grow besides water and sunlight?"  
  "What does a clock measure?"  
  "What animal goes 'ribbit'?"  
  "What is the opposite of 'up'?"  
  "What does the sun provide to Earth?"  
  "What color is an emerald?"  
  "Which planet is closest to the sun?"  
  "Who is the author of *Harry Potter*?"  
  "What do you use an umbrella for?"  
  "What is the opposite of 'fast'?"  
  "What is the name of the ship that sank after hitting an iceberg?"  
  "How many minutes are in an hour?"  
  "What do fish use to breathe?"  
  "What is the name of the tallest mountain in the world?"  
  "What do you call a young frog?"  
  "Which animal has black and white stripes?"  
  "What is the name of the fairy tale girl with long, golden hair?"  
  "Which month has 28 or 29 days?"  
  "What do you use to brush your teeth?"  
  "What is the color of an orange fruit?"  
  "What is the name of the frozen water that falls from the sky in winter?"  
  "Which direction does the sun rise from?"  
  "What do you call a group of wolves?"  
  "What do you use a hammer for?"  
  "What is the shape of a full moon?"  
  "What is the opposite of 'happy'?"  
  "Which fruit is green on the outside and red on the inside with black seeds?"  
  "How many legs does an octopus have?"  
  "What do you call a baby horse?"  
  "What is the first letter of the alphabet?"  
  "Which sea creature has eight arms?"  
  "Where do kangaroos live?"  
  "What is the main ingredient in bread?"  
  "What do astronauts wear in space?"  
  "Which holiday is known for fireworks and independence?"  
  "What does a traffic light’s red color mean?"  
  "What do you call a person who flies an airplane?"
)

# Ask the user to input API Key and Domain URL
echo -n "Enter your API Key: "
read api_key
echo -n "Enter the Domain URL: "
read api_url

# Exit if the API Key or URL is empty
if [ -z "$api_key" ] || [ -z "$api_url" ]; then
    echo "Error: Both API Key and Domain URL are required!"
    exit 1
fi

# Set number of threads to 1 (default)
num_threads=1
echo "✅ Using 1 thread..."

# Function to run the single thread
start_thread() {
    while true; do
        # Pick a random message from the predefined list
        random_message="${user_messages[$RANDOM % ${#user_messages[@]}]}"
        send_request "$random_message" "$api_key" "$api_url"
    done
}

# Start the single thread
start_thread &

# Wait for the thread to finish (this will run indefinitely)
wait

# Graceful exit handling (SIGINT, SIGTERM)
trap "echo -e '\n🛑 Process terminated. Exiting gracefully...'; exit 0" SIGINT SIGTERM
