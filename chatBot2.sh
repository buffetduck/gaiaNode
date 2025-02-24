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
           "Explain why the sky appears blue during the day."  
            "Describe the life cycle of a butterfly."  
            "How does photosynthesis work in plants?"  
            "List three causes of climate change and explain their effects."  
            "What are the main differences between a democracy and a dictatorship?"  
            "Explain how the water cycle works."  
            "Describe the role of the heart in the circulatory system."  
            "How do vaccines help protect against diseases?"  
            "What are three key differences between mammals and reptiles?"  
            "Describe how earthquakes occur and what causes them."  
            "Explain why the moon has different phases."  
            "What are some ways humans can reduce their carbon footprint?"  
            "How does gravity affect objects on Earth and in space?"  
            "Describe the process of making chocolate from cocoa beans."  
            "Explain why the seasons change throughout the year."  
            "How does the internet work in simple terms?"  
            "Why do people get jet lag when traveling across time zones?"  
            "Describe the structure of an atom."  
            "What are three major causes of ocean pollution?"  
            "Explain the importance of the ozone layer and what threatens it."  
            "Describe the basic process of digestion in the human body."  
            "How do bees contribute to the environment?"  
            "Why do we experience day and night?"  
            "Explain the difference between renewable and non-renewable energy sources."  
            "How does a plane stay in the air?"  
            "Describe the difference between a solar and a lunar eclipse."  
            "What are some of the benefits of reading regularly?"  
            "How does a refrigerator keep food cold?"  
            "Explain why exercise is important for a healthy lifestyle."  
            "Describe how sound travels and why it cannot move through space."  
            "Why do leaves change color in the fall?"  
            "What are the basic ingredients needed to bake a cake?"  
            "How do magnets work?"  
            "Describe how a rainbow is formed."  
            "What are some ways animals adapt to survive in the desert?"  
            "How do submarines dive and resurface?"  
            "Explain how the stock market functions in simple terms."  
            "What are the main differences between a comet and an asteroid?"  
            "How do scientists determine the age of fossils?"  
            "Why does ice float on water instead of sinking?"  
            "Explain how Wi-Fi allows devices to connect to the internet."  
            "How does a camera capture an image?"  
            "Why do humans need sleep?"  
            "Describe how bridges are built to support heavy loads."  
            "How does sunscreen protect the skin from UV rays?"  
            "What causes a tsunami and how does it affect coastal areas?"  
            "Explain the importance of recycling and how it helps the environment."  
            "Why do some countries drive on the left side of the road?"  
            "How does a GPS system determine a person's location?"  
            "What are some of the main reasons animals migrate?"  
            "Describe how a television screen displays moving images."  
            "Why do people get goosebumps when they feel cold or scared?"  
            "Explain how an electric car works."  
            "What are the key differences between bacteria and viruses?"  
            "How do wind turbines generate electricity?"  
            "Describe how the human brain processes information."  
            "Why do birds have hollow bones?"  
            "How does a compass work?"  
            "Explain how a parachute slows down a falling object."  
            "Why do people yawn, and is it really contagious?"  
            "Describe how money is printed and circulated in an economy."  
            "How do trees help combat climate change?"  
            "What are some ways people purify water to make it safe to drink?"  
            "Explain how a solar panel converts sunlight into electricity."  
            "Why do astronauts wear spacesuits?"  
            "How does the process of fermentation work in food production?"  
            "Describe how fireworks produce different colors when they explode."  
            "How do ants communicate with each other?"  
            "Why do volcanoes erupt, and what happens when they do?"  
            "How does a microwave oven heat food?"  
            "Explain why deep-sea creatures have unique adaptations for survival."  
            "What are some of the benefits of meditation for mental health?"  
            "How do airplanes navigate in the sky without getting lost?"  
            "Describe how music affects human emotions and mood."  
            "Why do humans have different blood types?"  
            "How does a hybrid car save fuel compared to a regular car?"  
            "Explain why flamingos are pink and not another color."  
            "What are some of the main reasons people experience stress?"  
            "How does a 3D printer work, and what are its uses?"  
            "Describe the process of making cheese from milk."  
            "Why do different animals have different sleep patterns?"  
            "How does a lighthouse help ships navigate safely?"  
            "Explain how boomerangs return when thrown correctly."  
            "What are the differences between freshwater and saltwater fish?"  
            "How do roller coasters use physics to create thrilling rides?"  
            "Why do some foods spoil faster than others?"  
            "Describe the greenhouse effect and its impact on global warming."  
            "How do dolphins communicate with each other underwater?"  
            "What are some ways people can improve their memory?"  
            "Explain why the human body needs vitamins and minerals."  
            "How does a bank store and protect money?"  
            "Why do metal objects feel colder to the touch than wooden ones?"  
            "How do submarines see underwater in deep darkness?"  
            "Describe how a soccer ball curves when kicked a certain way."  
            "How does an hourglass measure time?"  
            "Why do humans experience dreams when they sleep?"  
            "Explain why some people are left-handed and others are right-handed."  
            "How does a fire extinguisher put out a fire?"  
            "What are some ways honeybees help farmers grow crops?"  
            "Why do stars twinkle when we look at them from Earth?"
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
