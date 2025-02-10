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
    "What is 1 + 1"
    "What is 2 + 2"
    "What is 3 + 1"
    "What happens inside a black hole?"
    "Could we ever create a machine that reads human thoughts?"
    "How close are we to achieving immortality through science?"
    "What would happen if we discovered life on another planet?"
    "Can artificial intelligence ever truly understand human emotions?"
    "What is the meaning of life, if there is one?"
    "Do humans have free will, or is everything predetermined?"
    "Is it possible to experience reality objectively, or is everything subjective?"
    "What defines 'consciousness,' and could machines ever possess it?"
    "If the universe is infinite, does that mean there are infinite versions of us?"
    "What caused the fall of ancient civilizations like the Maya or the Roman Empire?"
    "How would history have changed if a major event (e.g., the Industrial Revolution) never happened?"
    "What lost knowledge from ancient cultures could benefit us today?"
    "How did early humans develop language and communication?"
    "What would the world look like if colonialism never occurred?"
    "Are we alone in the universe, or is life common?"
    "What existed before the Big Bang?"
    "Could there be parallel universes, and how would they differ from ours?"
    "What would happen if we could travel faster than the speed of light?"
    "Is time travel theoretically possible, and what would be the consequences?"
    "Why do humans create art, and what purpose does it serve?"
    "What drives people to believe in conspiracy theories?"
    "Can true equality ever be achieved in society?"
    "Why do humans dream, and do dreams have meaning?"
    "What would happen if money no longer existed?"
    "What will the world look like in 100 years?"
    "Will humans ever colonize other planets?"
    "How will climate change reshape the Earth’s future?"
    "Could we one day merge human brains with computers?"
    "What ethical dilemmas will arise from advancing biotechnology?"
    "Do ghosts or supernatural phenomena exist?"
    "What causes déjà vu, and why does it feel so strange?"
    "Are there undiscovered species on Earth that could change our understanding of biology?"
    "What is dark matter, and how does it shape the universe?"
    "Why do some people experience near-death experiences, and what do they mean"
    "What is 4 + 2"
    "What is 5 + 3"
    "What is 6 + 1"
    "What is 7 + 2"
    "What is 8 + 3"
    "What is 9 + 1"
    "What is 10 + 5"
    "What is 7 + 5"
    "What is 9 + 6"
    "What is 11 + 2"
    "What is 12 + 3"
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
