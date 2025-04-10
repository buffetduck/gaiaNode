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
    "How do fireflies produce light?"  
"Explain the role of chlorophyll in plants."  
"How do fish breathe underwater?"  
"Describe how a seed turns into a tree."  
"Why does metal feel colder than wood at the same temperature?"  
"Explain the difference between high tide and low tide."  
"How do birds stay warm in the winter?"  
"Describe how a GPS calculates your location."  
"Why do airplanes leave white trails in the sky?"  
"Explain why some people are left-handed."  
"How do solar panels generate electricity?"  
"Describe how a vending machine works."  
"Why does salt help preserve food?"  
"How do mirrors reflect light?"  
"Explain the difference between a debit card and a credit card."  
"Why do camels have humps?"  
"How do whales hold their breath for so long?"  
"Describe how an hourglass measures time."  
"Why do stars twinkle at night?"  
"How do submarines navigate underwater?"  
"Explain how a thermostat controls temperature."  
"How do bees make honey?"  
"Describe how a zipper works."  
"Why does the Moon have craters?"  
"How do plants 'breathe' through their leaves?"  
"Explain why soap creates bubbles."  
"How does a compass always point north?"  
"Describe the purpose of airbags in a car."  
"Why do onions make you cry?"  
"How do glow-in-the-dark objects work?"  
"Explain why popcorn pops."  
"How do airplanes take off and land?"  
"Describe how a touch screen detects your fingers."  
"Why do flamingos stand on one leg?"  
"How do electric cars charge their batteries?"  
"Explain how a speaker produces sound."  
"Why do helium balloons float in the air?"  
"How do ice skates glide on ice?"  
"Describe how a vacuum cleaner works."  
"Why do some insects walk on water?"  
"How does a smoke detector sense smoke?"  
"Explain how a magnet attracts metal."  
"Why does yawning seem contagious?"  
"How do self-driving cars detect obstacles?"  
"Describe how a battery stores energy."  
"Why does sugar dissolve faster in hot water?"  
"How does a 3D movie work?"  
"Explain how electric eels produce electricity."  
"Why do birds sing?"  
"How do boomerangs return when thrown?"  
"Describe how a sundial tells time."  
"Why do bubbles always form spheres?"  
"How does a roller skate move?"  
"Explain why glass is transparent."  
"Why do some animals hibernate?"  
"How do drones stay stable in the air?"  
"Describe how a matchstick produces fire."  
"Why do our fingers wrinkle in water?"  
"How do rainbows form after rain?"  
"Explain how a cuckoo clock works."  
"Why do people blush?"  
"How does Wi-Fi transmit data?"  
"Describe how a candle burns."  
"Why do chameleons change color?"  
"How do animals see in the dark?"  
"Explain how a gyroscope maintains balance."  
"Why do zebras have stripes?"  
"How do vending machines know which coin is inserted?"  
"Describe how an escalator moves."  
"Why do cats purr?"  
"How does an Etch-a-Sketch erase drawings?"  
"Explain why some people get car sick."  
"How do wind chimes produce sound?"  
"Describe how a lava lamp works."  
"Why do magnets have north and south poles?"  
"How does a fire extinguisher put out flames?"  
"Explain why wool keeps you warm."  
"Why do turtles retract their heads into their shells?"  
"How do airplanes fly upside down?"  
"Describe how a frisbee stays in the air."  
"Why do some people talk in their sleep?"  
"How does a cuckoo clock keep time?"  
"Explain why shadows change size during the day."  
"How do birds fly without flapping their wings?"  
"Describe how glow sticks produce light."  
"Why do hot air balloons rise?"  
"How do vending machines prevent theft?"  
"Explain how a Polaroid camera works."  
"Why do fire trucks have sirens?"  
"How do car brakes stop a vehicle?"  
"Describe why some rocks are magnetic."  
"Why do some fish glow in the dark?"  
"How does a submarine control its depth?"  
"Explain why some leaves change color in autumn."  
"Why do microwave ovens heat food evenly?"  
"How do icebergs float in the ocean?"  
"Describe how windmills generate power."  
"Why do turtles live so long?"  
"How does a jukebox select a song?"  
"Explain how a barometer measures air pressure."  
"Why do different animals have different types of teeth?"  
"How do water slides make you go fast?"  
"Describe how a metal detector finds hidden objects."  
"Why do clocks make ticking sounds?"  
"How does a hologram create a 3D image?"
"Why do stars shine?"
"How do ants carry objects much heavier than themselves?"
"Why does metal expand when heated?"
"How do plants absorb water from the soil?"
"Why do birds have hollow bones?"
"How do viruses spread?"
"Why does the moon sometimes appear larger?"
"How do bacteria multiply?"
"Why do some fish live in freshwater while others live in saltwater?"
"How does photosynthesis produce oxygen?"
"Why do objects fall at the same rate in a vacuum?"
"How do owls rotate their heads so far?"
"Why do dogs have a stronger sense of smell than humans?"
"How do octopuses camouflage themselves?"
"Why do volcanoes erupt?"
"How does the nervous system send signals?"
"Why do birds migrate?"
"How do electric eels generate electricity?"
"Why do human eyes have a blind spot?"
"How does a solar eclipse occur?"
"Why does rubbing your hands together create heat?"
"How do dolphins communicate?"
"Why do bats hang upside down?"
"How do plants grow toward sunlight?"
"Why does water boil faster at higher altitudes?"
"How do seeds germinate?"
"Why do chameleons change color?"
"How does a spider create its web?"
"Why does helium make your voice sound higher?"
"How do sharks detect movement in the water?"
"Why do birds sing?"
"How does a caterpillar turn into a butterfly?"
"Why do we feel dizzy when spinning?"
"How do bees recognize flowers?"
"Why do whales have blowholes?"
"How do desert animals survive with little water?"
"Why do cats land on their feet?"
"How does a thermometer measure temperature?"
"Why do ice cubes float?"
"How do leaves change color in autumn?"
"Why do cacti have spines instead of leaves?"
"How do penguins stay warm in the cold?"
"Why do turtles live so long?"
"How do fireflies glow?"
"Why do we yawn?"
"How do mushrooms grow?"
"Why do some birds fly in a V formation?"
"How does a plane's black box work?"
"Why do snakes shed their skin?"
"How does a rocket launch into space?"
"Why do submarines stay underwater without floating up?"
"How does a camera capture an image?"
"Why do satellites stay in orbit?"
"How does a smartphone detect touch?"
"Why do traffic lights have three colors?"
"How does a microwave heat food?"
"Why do electric cars need charging stations?"
"How does a GPS find your location?"
"Why do wind turbines generate electricity?"
"How does Wi-Fi work?"
"Why do drones stay balanced in the air?"
"How does a fingerprint scanner work?"
"Why do some bridges have suspension cables?"
"How does an elevator move up and down?"
"Why do car airbags inflate so quickly?"
"How does a Bluetooth connection work?"
"Why do airplanes fly at high altitudes?"
"How does a speaker produce sound?"
"Why do QR codes store information?"
"How does a touchscreen respond to fingers?"
"Why do electric circuits need a closed loop?"
"How does a self-driving car detect obstacles?"
"Why do some robots use artificial intelligence?"
"How does a vending machine recognize coins?"
"Why do windmills turn?"
"How does a television display images?"
"Why do some trains use magnets instead of wheels?"
"How does a smartwatch track your steps?"
"Why do solar panels convert sunlight into energy?"
"How does a barcode scanner work?"
"Why do airplanes have pressurized cabins?"
"How does an ATM process transactions?"
"Why do some skyscrapers sway in the wind?"
"How does a remote control send signals?"
"Why do smart home devices connect to the internet?"
"How does a telescope magnify objects?"
"Why do some materials conduct electricity while others don’t?"
"How does a car engine convert fuel into motion?"
"Why do hoverboards balance themselves?"
"How does a 3D printer create objects?"
"Why do electric trains run without fuel?"
"How does an electric kettle heat water?"
"Why do solar-powered calculators work without batteries?"
"How does the sun produce energy?"
"Why do astronauts float in space?"
"How does Earth's gravity hold the moon in orbit?"
"Why do some planets have rings?"
"How does a black hole form?"
"Why do we see different constellations at different times of the year?"
"How does a telescope magnify distant objects?"
"Why do some stars appear red and others blue?"
"How does a space probe send information back to Earth?"
"Why do meteors burn up in the atmosphere?"
"How does Mars have seasons?"
"Why do planets orbit the sun?"
"How does a lunar eclipse happen?"
"Why do comets have tails?"
"How does a supernova occur?"
"Why do astronauts wear space suits?"
"How does an asteroid belt form?"
"Why do space stations stay in orbit?"
"How does Earth's atmosphere protect us from space radiation?"
"Why do some planets have more moons than others?"
"Why did the Great Wall of China get built?"
"How did the pyramids get constructed?"
"Why do countries have different time zones?"
"How did the Industrial Revolution change society?"
"Why do some languages have similar words?"
"How did ancient civilizations measure time?"
"Why do some countries have multiple official languages?"
"How did explorers navigate without modern tools?"
"Why do oceans have currents?"
"How did World War I start?"
"Why do some continents drift apart?"
"How did ancient Rome influence modern law?"
"Why do we celebrate Independence Day?"
"How did the Renaissance change art?"
"Why do some deserts have sand dunes?"
"How did people travel before airplanes?"
"Why do rivers create valleys?"
"How did the first maps get drawn?"
"Why do some cities grow faster than others?"
"How did early humans migrate across continents?"
"Why do some people love spicy food?"
"How does a lie detector work?"
"Why do cats sleep so much?"
"How does a magic trick fool the brain?"
"Why do we get hiccups?"
"How do optical illusions work?"
"Why do dogs wag their tails?"
"How does laughter affect the brain?"
"Why do people love roller coasters?"
"How does music affect emotions?"
"Why do we bite our nails when nervous?"
"How do tattoos stay on the skin?"
"Why do we feel ticklish?"
"How does a fortune cookie get its message inside?"
"Why do we remember song lyrics so well?"
"How does caffeine keep you awake?"
"Why do babies laugh?"
"How does stress affect the body?"
"Why do some people love horror movies?"
"How do people learn languages?"
"Why did the Titanic sink?"
"How did ancient civilizations build pyramids?"
"Why did the Roman Empire fall?"
"How did World War II start?"
"Why do people celebrate New Year’s Eve?"
"How did the printing press change the world?"
"Why do we have national holidays?"
"How did the Internet change communication?"
"Why do some countries drive on the left side?"
"How did ancient people tell time?"
"Why did people believe the Earth was flat?"
"How did humans first domesticate animals?"
"Why do some cultures eat different foods?"
"How did the Industrial Revolution change transportation?"
"Why do we have different religions?"
"How did the Great Depression happen?"
"Why do some countries have kings and queens?"
"How did democracy originate?"
"Why do we use paper money?"
"How did space exploration begin?"
"Why do earthquakes happen?"
"How do tsunamis form?"
"Why do volcanoes exist?"
"How do mountains form?"
"Why does the Earth rotate?"
"How do glaciers shape the land?"
"Why do deserts have extreme temperatures?"
"How does the ocean regulate Earth's climate?"
"Why do some places have monsoons?"
"How do tornadoes form?"
"Why do different places have different climates?"
"How does the water cycle work?"
"Why do rivers curve?"
"How do caves form?"
"Why do islands exist?"
"How does deforestation affect the environment?"
"Why do we experience seasons?"
"How do sand dunes form?"
"Why do continents drift apart?"
"How does soil erosion happen?"
"Why does multiplication work the way it does?"
"How do fractions relate to decimals?"
"Why is zero important in mathematics?"
"How do prime numbers work?"
"Why do angles add up to 180 degrees in a triangle?"
"How does the Pythagorean theorem work?"
"Why do we use algebra?"
"How do probability calculations work?"
"Why do we need negative numbers?"
"How does compound interest grow money?"
"Why does π (pi) never end?"
"How do logarithms simplify calculations?"
"Why do even numbers always end in 0, 2, 4, 6, or 8?"
"How does geometry help in real life?"
"Why do we need statistics?"
"How does a calculator perform division?"
"Why do we round numbers?"
"How does a Sudoku puzzle use logic?"
"Why does the Fibonacci sequence appear in nature?"
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

# Ask the user to input the delay between questions
echo -n "Enter the delay between questions (in seconds): "
read delay_between_questions

# Validate the delay input
if ! [[ "$delay_between_questions" =~ ^[0-9]+$ ]]; then
    echo "Error: Delay must be a positive integer!"
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
        
        # Add a delay between questions
        sleep "$delay_between_questions"
    done
}

# Start the single thread
start_thread &

# Wait for the thread to finish (this will run indefinitely)
wait

# Graceful exit handling (SIGINT, SIGTERM)
trap "echo -e '\n🛑 Process terminated. Exiting gracefully...'; exit 0" SIGINT SIGTERM
