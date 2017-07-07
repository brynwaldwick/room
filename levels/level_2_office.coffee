
# needs death scenes

module.exports = {
    index: 2
    name: 'Office'
    triggers: [
        postCreate:
            message: (new_item) ->
                if new_item.sender == 'aviana'
                    console.log 'hello'
                    # send message to president
    ]
    story: {
        Room:
            inspect:
                "-- There seems to be a postmaster servicing the old cluster... -- \n 
                The machine breathes an announcement into the room. A stare and a pause. A #man in a suit paces across the carpet and peers menacingly into a tiny screen. \n
                -- And when is he going to finish? -- \n
                "
            Man: "
                He mulls simple decisions, compared to those men of older ages. \n
                These days men make simple decisions. The decisions and the men themselves are broken down and made simpler and they are faster and it feels like there is less to them. The process is clinical as much as it is chemical. Industrial. Want. And. Emotion. People end up where they don't belong. \n
                \n \n
                To wit, you are in a room. There is a #desk near the back wall. Some #windows behind it, thick glass. A blue #rug, #tables. #Doors. Perhaps the largest departure from any image in your mind right now is the #robot that swivles through the room."
            President:
                inspect: "The @president only ever listened to @aviana."
            Desk:
                inspect: "The desk is more than that of an enterprising man. It is stately. It speaks to power. It lays bare save for a curious set of items: two mobile #phones, a #green_button, and a nearly unironic, larger #red_button."
                "Green Button": "Small and green"
                "Red Button": "Big and red"
                Phones: "One to a hole you don't know about, one to somewhere else entirely. You can't touch them."
            Tables:
                inspect: "Holding #pens, #candles, #ornaments. "
                Pens:
                    inspect: "A small herd of pens, each with a seal matching the #rug."
                    take: (context) ->
                        return "You can't take a pen unless you have an appointment"
                Ornaments:
                    inspect: "Crystal bodies with etchings. A bit nondescript."
                    take: (context) ->
                        return "Do not take."
                Candles:
                    inspect: "Never lit. One with proprietary #listening_devices"
                    take: (context) ->
                        return "That would be unwise."
            "Listening Devices": "A retina scan is required to use these. It's so small that that's all I can tell you."
            Doors: "To where exactly? The odd garden; a vestibule; a secret tunnel..."
            Rug: "A blue rug, with a round seal. A bird form and symbols of war and justice round out the #furnishings."
            Pictures: "Titans of old; portraits of men; power and smoke; one with proprietary #listening_devices."
            Furnishings: "Symbols of power and of commerce. The #rug, the #phones, the #man, and of course the #robot."
            Lamp:
                inspect: "It looks like it was bought in IKEA. Seems slightly unsturdy to boot."
                take: (context) ->
                    context.Lamp?.health -= 0.1
                    return "The lamp rattles. Please don't touch that, says Aviana"
            Robot: "The #Aviana Presidential Assistant hovers in the office. She was a secret DARPA project; a crowdsourced intelligence robot built to help the Commander in Chief serve the people of his country. \n
            The two were joined at the hip in 2063 and have evolved a sort of communist dictator, tourettes victim, old married couple, dying binary star #dynamic of deep pessimism and the lowest common denominator projected onto itself."
            Dynamic: 'They would one day write in the history books: "When #Aviana talked, the #President listened."'
            Aviana: "@aviana was named for somebody's granddaughter"
    }
}

