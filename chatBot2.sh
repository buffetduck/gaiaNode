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
            "What are the main differences between a crocodile and an alligator?"  
"Explain how photosynthesis works in plants."  
"Describe the water cycle and its main stages."  
"What causes the different phases of the moon?"  
"How does a bill become a law in the United States?"  
"What are three major causes of climate change?"  
"Describe the life cycle of a butterfly."  
"How do vaccines help protect against diseases?"  
"What are the main functions of the human liver?"  
"Explain the difference between a simile and a metaphor with examples."  
"What are the key characteristics of mammals?"  
"How does an earthquake occur?"  
"Describe the process of making chocolate from cacao beans."  
"What are the primary responsibilities of the President of a country?"  
"Explain the difference between renewable and nonrenewable energy sources."  
"How do airplanes stay in the air?"  
"What are the main parts of a cell and their functions?"  
"Describe how tides are influenced by the moon."  
"What are the major differences between the inner and outer planets of our solar system?"  
"How does the greenhouse effect contribute to global warming?"  
"Explain the importance of the three branches of government in a democracy."  
"How do bees communicate with each other?"  
"What are the main causes of deforestation?"  
"Describe how sound waves travel through different mediums."  
"What are the main ingredients in a pizza, and how is it made?"  
"How do magnets work and what are their uses?"  
"Explain the difference between a democracy and a dictatorship."  
"What are the steps involved in the scientific method?"  
"How does a rainbow form?"  
"Describe how ocean currents affect global weather patterns."  
"What is the purpose of the United Nations?"  
"How do submarines dive and resurface?"  
"Explain how supply and demand affect prices in an economy."  
"How does the human eye perceive color?"  
"What are some key differences between novels and short stories?"  
"Describe the process of photosynthesis in detail."  
"How do ants work together in a colony?"  
"Explain the concept of gravity and how it affects motion."  
"Why do some animals hibernate in winter?"  
"Describe the process of digestion in humans."  
"What are the advantages and disadvantages of solar energy?"  
"How do coral reefs form, and why are they important?"  
"Explain the main differences between weather and climate."  
"What is the importance of the ozone layer?"  
"How do volcanoes erupt?"  
"Describe the journey of a drop of water through the water cycle."  
"How does a camera capture an image?"  
"What are the benefits of eating a balanced diet?"  
"Explain how wind is formed and why it varies in speed."  
"What are the basic steps to writing a good essay?"  
"Describe how honeybees produce honey."  
"How do fish breathe underwater?"  
"Explain the significance of the Great Wall of China."  
"Why is recycling important for the environment?"  
"How does an electric car work?"  
"Describe how a smartphone connects to the internet."  
"What is artificial intelligence, and how is it used today?"  
"How do professional athletes train for competitions?"  
"Explain the process of making paper from trees."  
"How does GPS technology work?"  
"What are the main steps in baking a cake?"  
"Describe the difference between natural and synthetic fabrics."  
"How do plants adapt to survive in the desert?"  
"Explain the importance of financial budgeting in daily life."  
"What are the effects of pollution on marine life?"  
"How does the human body regulate temperature?"  
"Describe how lightning and thunder are related."  
"What are the main types of rock formations?"  
"How do fingerprints form, and why are they unique?"  
"Explain the role of DNA in genetics."  
"How do scientists determine the age of fossils?"  
"What are the causes and effects of acid rain?"  
"Describe how birds are able to fly."  
"How does social media influence modern communication?"  
"Explain how vaccines help build immunity against diseases."  
"Why do we experience jet lag after long flights?"  
"How does caffeine affect the human body?"  
"What are the different types of clouds and how do they form?"  
"Describe how a mechanical clock works."  
"How do artists use perspective to create depth in paintings?"  
"Explain how human activities contribute to global warming."  
"How does a seed grow into a plant?"  
"What are the benefits of exercising regularly?"  
"How does a microwave oven heat food?"  
"Describe the major steps in treating drinking water."  
"How do touchscreens recognize user input?"  
"Explain the importance of teamwork in sports and the workplace."  
"How do different animals use camouflage to survive?"  
"What are the key features of a good persuasive argument?"  
"Describe the role of bacteria in the ecosystem."  
"How does a roller coaster work?"  
"What are the effects of sleep deprivation on the brain?"  
"Explain how credit cards work and their potential risks."  
"How does music affect human emotions?"  
"Describe how a parachute slows down a skydiver."  
"How do wind turbines generate electricity?"  
"What are the challenges of space travel for astronauts?"  
"Explain the main differences between a debit card and a credit card."  
"How does an athlete’s diet affect their performance?"  
"What are the effects of overfishing on marine ecosystems?"  
"Describe how solar panels convert sunlight into electricity."  
"How does the brain process and store memories?"  
"Why do some foods spoil faster than others?"  
"Explain the importance of biodiversity in an ecosystem."
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
