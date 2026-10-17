# By Mara Msingi
"""KICD-aligned seed data for the five Msingi AI benchmark grades.

Mock content modelled on the KICD Competency Based Education designs for
PP2, Grade 3, Grade 6, Grade 9 and Grade 12 (Senior School pathways). It is
illustrative demo data, not an official reproduction of the curriculum
designs. Each grade carries learning areas -> strands -> sub-strands plus one
demo learner, parent and progress record so every view works out of the box.
"""

glob CORE_COMPETENCIES: list[str] = [
    "Communication and Collaboration",
    "Critical Thinking and Problem Solving",
    "Creativity and Imagination",
    "Citizenship",
    "Digital Literacy",
    "Learning to Learn",
    "Self-efficacy"
];

glob NATIONAL_VALUES: list[str] = [
    "Love", "Responsibility", "Respect", "Unity", "Peace", "Patriotism",
    "Social Justice", "Integrity"
];

glob KNEC_LEVELS: dict[str, str] = {
    "EE": "Exceeding Expectations",
    "ME": "Meeting Expectations",
    "AE": "Approaching Expectations",
    "BE": "Below Expectations"
};

glob KNEC_SCORES: dict[str, int] = {"EE": 4, "ME": 3, "AE": 2, "BE": 1};

glob DEMO_TEACHER: dict[str, str] = {
    "name": "Tr. Faith Njeri",
    "school": "Msingi Demo School",
    "county": "Nakuru"
};

glob KICD_SEED: list[dict[str, any]] = [
    # ------------------------------------------------------------------ PP2
    {
        "code": "PP2",
        "label": "Pre-Primary 2",
        "stage": "Early Years Education (Pre-Primary)",
        "age_range": "5 to 6 years",
        "assessment": "School-based observation and portfolio; transition readiness for Grade 1",
        "focus": "Language, Mathematical, Environmental, Psychomotor and Creative Activities",
        "order": 1,
        "lesson_minutes": 30,
        "daily_study_minutes": 15,
        "learner_profile": "Learns through play, songs, stories and touch. Attention span of about 10 to 15 minutes. Needs concrete objects, movement and lots of praise. No written homework.",
        "areas": [
            {
                "name": "Language Activities",
                "description": "Listening, speaking, pre-reading and pre-writing readiness.",
                "strands": [
                    {
                        "name": "Listening and Speaking",
                        "core_competencies": ["Communication and Collaboration", "Self-efficacy"],
                        "values": ["Respect", "Love"],
                        "pcis": ["Life Skills: self-awareness", "Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Pronunciation and Vocabulary",
                                "slos": [
                                    "Pronounce sounds of letters correctly in songs and rhymes",
                                    "Name common items found at home and in class",
                                    "Enjoy using new words in short conversations"
                                ],
                                "kiqs": ["What do we call the things we use at home?", "Which sound does your name start with?"],
                                "experiences": ["Sing action songs and rhymes", "Play 'I spy' with classroom objects", "Talk about pictures in pairs"],
                                "resources": ["Picture cards", "Real objects", "Song charts"],
                                "local_materials": ["Cut-out pictures from old calendars", "Cooking pots and cups", "Bottle tops"],
                                "home_activity": "While cooking, name each item you use and let the child repeat the word and its first sound."
                            }
                        ]
                    },
                    {
                        "name": "Pre-reading",
                        "core_competencies": ["Learning to Learn", "Critical Thinking and Problem Solving"],
                        "values": ["Responsibility"],
                        "pcis": ["Reading culture"],
                        "sub_strands": [
                            {
                                "name": "Picture Reading",
                                "slos": [
                                    "Tell a short story from a series of pictures",
                                    "Hold a book the right way and turn pages one at a time",
                                    "Show interest in books and pictures"
                                ],
                                "kiqs": ["What is happening in this picture?", "What do you think will happen next?"],
                                "experiences": ["Read big books together", "Arrange 3 picture cards in order", "Retell a story using puppets"],
                                "resources": ["Big books", "Sequencing cards", "Puppets"],
                                "local_materials": ["Old magazines", "Socks for puppets", "Manila paper"],
                                "home_activity": "Look at a newspaper or calendar picture together and ask the child to tell you what is happening."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Mathematical Activities",
                "description": "Classification, counting, number recognition and early measurement through play.",
                "strands": [
                    {
                        "name": "Numbers",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Learning to Learn"],
                        "values": ["Unity", "Responsibility"],
                        "pcis": ["Financial Literacy: counting money items"],
                        "sub_strands": [
                            {
                                "name": "Rote Counting and Number Recognition",
                                "slos": [
                                    "Count forward from 1 to 50 in songs and games",
                                    "Recognise numerals 1 to 9",
                                    "Match a group of objects with the right numeral"
                                ],
                                "kiqs": ["How many legs does a chair have?", "Which group has more?"],
                                "experiences": ["Count bottle tops in groups", "Hop and count on a number line drawn on the ground", "Sing counting songs"],
                                "resources": ["Number cards", "Counters", "Number line"],
                                "local_materials": ["Bottle tops", "Seeds (beans, maize)", "Sticks", "Pebbles"],
                                "home_activity": "Count beans or cups at mealtime together, then ask the child to show you the matching number on a calendar."
                            }
                        ]
                    },
                    {
                        "name": "Measurement",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Communication and Collaboration"],
                        "values": ["Respect"],
                        "pcis": ["Safety"],
                        "sub_strands": [
                            {
                                "name": "Comparing Length (Long and Short)",
                                "slos": [
                                    "Compare two objects using the words long, short, longer and shorter",
                                    "Arrange 3 objects from shortest to longest",
                                    "Enjoy measuring things in their surroundings"
                                ],
                                "kiqs": ["Which stick is longer?", "How can we find out who is taller?"],
                                "experiences": ["Compare sticks and strings outdoors", "Line up from shortest to tallest"],
                                "resources": ["Strings", "Sticks of different lengths"],
                                "local_materials": ["Sisal strings", "Sticks", "Maize stalks", "Old shoelaces"],
                                "home_activity": "Compare spoons, sticks or shoes at home and ask the child which is longer or shorter."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Environmental Activities",
                "description": "Exploring the social and natural environment, weather, and personal safety.",
                "strands": [
                    {
                        "name": "Natural Environment",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Citizenship"],
                        "values": ["Responsibility", "Love"],
                        "pcis": ["Environmental Education", "Disaster Risk Reduction"],
                        "sub_strands": [
                            {
                                "name": "Weather Conditions",
                                "slos": [
                                    "Identify sunny, rainy, windy and cloudy weather",
                                    "Dress appropriately for different weather",
                                    "Record the weather daily using simple symbols"
                                ],
                                "kiqs": ["What is the weather like today?", "What do we wear when it rains?"],
                                "experiences": ["Go outside and observe the sky", "Draw weather symbols on a class chart", "Role play dressing for rain"],
                                "resources": ["Weather chart", "Picture cards"],
                                "local_materials": ["Old clothes", "Leaves", "Bottle top wind spinners"],
                                "home_activity": "Each morning, ask the child to look outside and say if it is sunny, rainy, windy or cloudy."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Psychomotor and Creative Activities",
                "description": "Gross and fine motor skills, painting, modelling, music and movement.",
                "strands": [
                    {
                        "name": "Creative Activities",
                        "core_competencies": ["Creativity and Imagination", "Self-efficacy"],
                        "values": ["Love", "Unity"],
                        "pcis": ["Life Skills: self-expression"],
                        "sub_strands": [
                            {
                                "name": "Painting and Modelling",
                                "slos": [
                                    "Paint pictures using fingers and brushes",
                                    "Model simple objects from clay or plasticine",
                                    "Talk about their own artwork with pride"
                                ],
                                "kiqs": ["What colours can we see around us?", "What can we make from clay?"],
                                "experiences": ["Finger painting with natural colours", "Model fruits from clay", "Display work in a class gallery"],
                                "resources": ["Paints", "Clay", "Brushes"],
                                "local_materials": ["Clay soil", "Charcoal", "Beetroot or flower juice for colour", "Feathers as brushes"],
                                "home_activity": "Mix a little soil and water to make clay and let the child model a cup, a fruit or an animal."
                            }
                        ]
                    },
                    {
                        "name": "Psychomotor Activities",
                        "core_competencies": ["Self-efficacy", "Communication and Collaboration"],
                        "values": ["Unity", "Peace"],
                        "pcis": ["Health Education: physical fitness", "Safety"],
                        "sub_strands": [
                            {
                                "name": "Locomotor Skills",
                                "slos": [
                                    "Hop, skip and jump in play",
                                    "Run and stop on a signal safely",
                                    "Take turns and play fairly with others"
                                ],
                                "kiqs": ["How many ways can we move our bodies?", "How do we play safely?"],
                                "experiences": ["Hopscotch", "Relay games", "Movement songs"],
                                "resources": ["Balls", "Ropes", "Whistle"],
                                "local_materials": ["Paper balls tied with string", "Sisal skipping rope", "Chalk or a stick to draw hopscotch"],
                                "home_activity": "Draw a hopscotch grid in the yard and play together for 10 minutes."
                            }
                        ]
                    }
                ]
            }
        ],
        "learner": {
            "name": "Amani Wanjiru",
            "parent": "Grace Wanjiru",
            "progress": [
                ["Language Activities", "ME", "Speaks confidently in class and loves rhymes."],
                ["Mathematical Activities", "AE", "Counts to 30 with support, still mixing up 6 and 9."],
                ["Environmental Activities", "EE", "Leads the daily weather chart with enthusiasm."],
                ["Psychomotor and Creative Activities", "ME", "Very creative with clay modelling."]
            ],
            "competencies": {"Communication and Collaboration": 3, "Critical Thinking and Problem Solving": 2, "Creativity and Imagination": 4, "Self-efficacy": 3},
            "values": ["Love", "Respect", "Unity"],
            "teacher_note": "Amani is cheerful and curious. Counting with objects at home will help with number recognition."
        }
    },
    # ------------------------------------------------------------------ Grade 3
    {
        "code": "Grade 3",
        "label": "Grade 3",
        "stage": "Lower Primary (End)",
        "age_range": "8 to 9 years",
        "assessment": "KNEC Grade 3 monitoring assessment (school-based, literacy and numeracy focus)",
        "focus": "Hygiene and Nutrition, Environmental Activities, Literacy and Indigenous Languages",
        "order": 2,
        "lesson_minutes": 30,
        "daily_study_minutes": 30,
        "learner_profile": "Reads short texts and writes simple sentences. Learns best through hands-on activities, songs, stories and short tasks of about 20 minutes. Needs concrete examples from home and community.",
        "areas": [
            {
                "name": "Hygiene and Nutrition Activities",
                "description": "Personal hygiene, food hygiene and healthy eating habits.",
                "strands": [
                    {
                        "name": "Personal Hygiene",
                        "core_competencies": ["Self-efficacy", "Learning to Learn"],
                        "values": ["Responsibility", "Respect"],
                        "pcis": ["Health Education", "Life Skills"],
                        "sub_strands": [
                            {
                                "name": "Care of the Teeth",
                                "slos": [
                                    "Identify materials used to clean teeth",
                                    "Demonstrate the correct way of brushing teeth",
                                    "Appreciate the importance of clean teeth"
                                ],
                                "kiqs": ["Why should we clean our teeth?", "What can we use to clean our teeth?"],
                                "experiences": ["Demonstrate brushing on a model", "Make a chewing stick from mswaki", "Sing a tooth-brushing song"],
                                "resources": ["Toothbrush", "Teeth model", "Charts"],
                                "local_materials": ["Mswaki (chewing stick)", "Clean cup of water", "Old toothbrush", "Egg tray as teeth model"],
                                "home_activity": "Brush teeth together after supper and let the child teach you the correct up-and-down movement."
                            }
                        ]
                    },
                    {
                        "name": "Food and Nutrition",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Communication and Collaboration"],
                        "values": ["Responsibility", "Unity"],
                        "pcis": ["Health Education: nutrition", "Food security"],
                        "sub_strands": [
                            {
                                "name": "Food Hygiene",
                                "slos": [
                                    "State ways of keeping food clean and safe",
                                    "Wash fruits and vegetables correctly before eating",
                                    "Practise covering food at home and in school"
                                ],
                                "kiqs": ["How does food get dirty?", "How can we keep our food safe?"],
                                "experiences": ["Wash fruits in groups", "Sort pictures of safe and unsafe food", "Make a food cover from a basket"],
                                "resources": ["Basins", "Picture cards", "Fruits"],
                                "local_materials": ["Basin and clean water", "Sukuma wiki or local fruits", "Old basket or netting"],
                                "home_activity": "Ask the child to wash and prepare the fruits or vegetables for supper while explaining each hygiene step."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Environmental Activities",
                "description": "Soil, water, weather, plants and caring for the community environment.",
                "strands": [
                    {
                        "name": "Natural Environment",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Citizenship"],
                        "values": ["Responsibility", "Love"],
                        "pcis": ["Environmental Education", "Climate change awareness"],
                        "sub_strands": [
                            {
                                "name": "Soil",
                                "slos": [
                                    "Identify sandy, clay and loam soil by touch",
                                    "Compare how much water each soil type holds",
                                    "Appreciate the uses of soil in the community"
                                ],
                                "kiqs": ["Why do plants grow better in some soils?", "Which soil holds the most water?"],
                                "experiences": ["Collect soil samples from the compound", "Water retention experiment with bottles", "Model pots from clay soil"],
                                "resources": ["Soil samples", "Funnels", "Measuring cups"],
                                "local_materials": ["Cut plastic bottles as funnels", "Cotton cloth or old socks as filters", "Soil from 3 places"],
                                "home_activity": "Collect a handful of soil from the garden and the roadside and talk about how they feel different."
                            }
                        ]
                    },
                    {
                        "name": "Social Environment",
                        "core_competencies": ["Citizenship", "Communication and Collaboration"],
                        "values": ["Patriotism", "Unity"],
                        "pcis": ["Citizenship", "Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Our County",
                                "slos": [
                                    "Name their county and its main features",
                                    "Identify leaders in the county",
                                    "Show respect for people of different communities"
                                ],
                                "kiqs": ["Which county do we live in?", "Who are the leaders in our county?"],
                                "experiences": ["Draw a simple map of the county", "Invite a local leader to talk to the class"],
                                "resources": ["Map of Kenya", "Pictures of leaders"],
                                "local_materials": ["Manila paper", "Newspaper cuttings of county news"],
                                "home_activity": "Talk with the child about the county you live in and the work your local chief or MCA does."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Literacy Activities",
                "description": "Reading fluency, comprehension and creative writing in English.",
                "strands": [
                    {
                        "name": "Reading",
                        "core_competencies": ["Communication and Collaboration", "Learning to Learn"],
                        "values": ["Respect", "Responsibility"],
                        "pcis": ["Reading culture", "Life Skills"],
                        "sub_strands": [
                            {
                                "name": "Reading Fluency",
                                "slos": [
                                    "Read a Grade 3 level text aloud at about 60 words per minute",
                                    "Read with correct pronunciation and expression",
                                    "Answer simple questions about a story"
                                ],
                                "kiqs": ["How can we read like a storyteller?", "What did the story teach us?"],
                                "experiences": ["Paired reading", "Echo reading with the teacher", "Class reading corner"],
                                "resources": ["Grade 3 readers", "Flash cards", "Timer"],
                                "local_materials": ["Old newspapers and magazines", "Product labels", "Homemade word cards from cereal boxes"],
                                "home_activity": "Ask the child to read a short story, label or newspaper heading aloud to the family every evening."
                            }
                        ]
                    },
                    {
                        "name": "Writing",
                        "core_competencies": ["Creativity and Imagination", "Communication and Collaboration"],
                        "values": ["Integrity"],
                        "pcis": ["Self-awareness"],
                        "sub_strands": [
                            {
                                "name": "Composition: Writing About Myself",
                                "slos": [
                                    "Write 5 simple sentences about themselves",
                                    "Use capital letters and full stops correctly",
                                    "Enjoy sharing their writing with others"
                                ],
                                "kiqs": ["What makes you special?", "How do we start and end a sentence?"],
                                "experiences": ["Draw and label 'All About Me' posters", "Share writing in the author's chair"],
                                "resources": ["Exercise books", "Pictures"],
                                "local_materials": ["Cardboard from boxes", "Family photos", "Charcoal or crayons"],
                                "home_activity": "Help the child write 3 sentences about their favourite family meal and read them aloud."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Indigenous Language Activities",
                "description": "Oral literature, listening and speaking in the language of the catchment area.",
                "strands": [
                    {
                        "name": "Listening and Speaking",
                        "core_competencies": ["Citizenship", "Communication and Collaboration"],
                        "values": ["Respect", "Patriotism", "Unity"],
                        "pcis": ["Cultural heritage", "Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Oral Narratives, Riddles and Proverbs",
                                "slos": [
                                    "Narrate a short story from their community",
                                    "Pose and answer riddles in the indigenous language",
                                    "Appreciate the wisdom in local proverbs"
                                ],
                                "kiqs": ["What stories do our grandparents tell?", "What lesson does this proverb teach?"],
                                "experiences": ["Story circle", "Riddle competitions", "Record an elder telling a story"],
                                "resources": ["Audio recordings", "Story books in the local language"],
                                "local_materials": ["A grandparent or elder as a resource person", "Phone voice recorder"],
                                "home_activity": "Ask a grandparent or elder to tell the child a story or riddle in your home language this weekend."
                            }
                        ]
                    }
                ]
            }
        ],
        "learner": {
            "name": "Baraka Otieno",
            "parent": "Christine Otieno",
            "progress": [
                ["Hygiene and Nutrition Activities", "EE", "Leads handwashing routine for the class."],
                ["Environmental Activities", "ME", "Enjoyed the soil experiment and explained results clearly."],
                ["Literacy Activities", "AE", "Reads about 45 words per minute; needs daily reading practice."],
                ["Indigenous Language Activities", "ME", "Knows many riddles in Dholuo."]
            ],
            "competencies": {"Communication and Collaboration": 3, "Critical Thinking and Problem Solving": 3, "Citizenship": 4, "Learning to Learn": 2},
            "values": ["Responsibility", "Respect"],
            "teacher_note": "Baraka is a natural leader. Ten minutes of reading aloud at home each day will lift fluency before the KNEC monitoring assessment."
        }
    },
    # ------------------------------------------------------------------ Grade 6
    {
        "code": "Grade 6",
        "label": "Grade 6",
        "stage": "Upper Primary (End)",
        "age_range": "11 to 12 years",
        "assessment": "KPSEA (Kenya Primary School Education Assessment) plus school-based assessment",
        "focus": "Science and Technology, Agriculture and Nutrition, Creative Arts and Social Studies",
        "order": 3,
        "lesson_minutes": 35,
        "daily_study_minutes": 60,
        "learner_profile": "Can read independently, carry out simple experiments and work in groups on projects. Focus of about 30 to 40 minutes. Motivated by real-life problems, competition and responsibility.",
        "areas": [
            {
                "name": "Science and Technology",
                "description": "Living things, energy, materials and the use of technology.",
                "strands": [
                    {
                        "name": "Living Things and Their Environment",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Learning to Learn"],
                        "values": ["Responsibility", "Love"],
                        "pcis": ["Health Education", "Drug and substance abuse awareness"],
                        "sub_strands": [
                            {
                                "name": "Human Circulatory System",
                                "slos": [
                                    "Identify the parts of the human circulatory system",
                                    "Describe the functions of the heart and blood vessels",
                                    "Measure their pulse rate at rest and after exercise"
                                ],
                                "kiqs": ["How does blood move around the body?", "Why does the heart beat faster when we run?"],
                                "experiences": ["Measure pulse before and after skipping", "Model the heart using bottles and tubes", "Watch a short animation"],
                                "resources": ["Charts", "Stopwatch", "Digital devices"],
                                "local_materials": ["Plastic bottles and drinking straws", "Red food colour or beetroot juice", "Wristwatch or phone timer"],
                                "home_activity": "Count each other's pulse for 30 seconds before and after carrying water or skipping, then compare."
                            }
                        ]
                    },
                    {
                        "name": "Force and Energy",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Creativity and Imagination", "Digital Literacy"],
                        "values": ["Responsibility", "Integrity"],
                        "pcis": ["Safety", "Energy conservation"],
                        "sub_strands": [
                            {
                                "name": "Electrical Energy: Simple Circuits",
                                "slos": [
                                    "Assemble a simple electric circuit",
                                    "Identify conductors and insulators",
                                    "Observe safety when handling electricity"
                                ],
                                "kiqs": ["What makes a bulb light up?", "Which materials allow electricity to pass?"],
                                "experiences": ["Build a circuit with a torch bulb and dry cells", "Test materials for conductivity"],
                                "resources": ["Dry cells", "Torch bulbs", "Connecting wires"],
                                "local_materials": ["Old torch and dry cells", "Foil from sweet wrappers", "Nails, coins, plastic and wood pieces for testing"],
                                "home_activity": "Use an old torch to show the child how the cells, bulb and switch work together. Never open mains sockets."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Agriculture and Nutrition",
                "description": "Conservation, food production and family nutrition.",
                "strands": [
                    {
                        "name": "Conservation of Resources",
                        "core_competencies": ["Citizenship", "Critical Thinking and Problem Solving"],
                        "values": ["Responsibility", "Unity"],
                        "pcis": ["Environmental Education", "Climate change adaptation"],
                        "sub_strands": [
                            {
                                "name": "Water Conservation",
                                "slos": [
                                    "Identify ways of harvesting and storing water",
                                    "Make a simple water harvesting structure",
                                    "Value water as a scarce resource"
                                ],
                                "kiqs": ["How can we collect rain water at home?", "How can we reuse water in the garden?"],
                                "experiences": ["Make a gutter from an iron sheet offcut", "Mulch a school garden bed", "Drip irrigation with bottles"],
                                "resources": ["Containers", "Gutters", "Mulch"],
                                "local_materials": ["Plastic bottles for drip irrigation", "Dry grass for mulch", "Old jerricans"],
                                "home_activity": "Set up a bottle drip system for one plant at home and check it every day for a week."
                            }
                        ]
                    },
                    {
                        "name": "Food Production Processes",
                        "core_competencies": ["Creativity and Imagination", "Self-efficacy"],
                        "values": ["Responsibility", "Love"],
                        "pcis": ["Food security", "Financial Literacy"],
                        "sub_strands": [
                            {
                                "name": "Kitchen Garden and Balanced Meals",
                                "slos": [
                                    "Prepare a sack or container kitchen garden",
                                    "Plan a balanced meal from locally available foods",
                                    "Appreciate growing their own food"
                                ],
                                "kiqs": ["What foods make a balanced meal?", "How can a small space grow food?"],
                                "experiences": ["Plant sukuma wiki in a sack garden", "Plan a balanced school lunch menu"],
                                "resources": ["Seeds", "Sacks", "Food pictures"],
                                "local_materials": ["Old gunny bags", "Kales or spinach seedlings", "Manure", "Small stones for drainage"],
                                "home_activity": "Plan tomorrow's supper together and check that it has energy, body-building and protective foods."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Creative Arts",
                "description": "Visual arts, music and performance drawing on Kenyan heritage.",
                "strands": [
                    {
                        "name": "Creating and Execution",
                        "core_competencies": ["Creativity and Imagination", "Communication and Collaboration"],
                        "values": ["Unity", "Patriotism"],
                        "pcis": ["Cultural heritage", "Talent development"],
                        "sub_strands": [
                            {
                                "name": "Weaving and Beadwork",
                                "slos": [
                                    "Weave a simple mat or basket using local fibres",
                                    "Design a bead pattern inspired by Kenyan cultures",
                                    "Appreciate crafts as a source of income"
                                ],
                                "kiqs": ["Which communities are known for beadwork?", "How can crafts earn money?"],
                                "experiences": ["Weave with sisal or banana fibre", "Design bracelets with repeating patterns"],
                                "resources": ["Beads", "Fibres", "Needles"],
                                "local_materials": ["Sisal or banana fibre", "Bottle tops and seeds as beads", "Old wool"],
                                "home_activity": "Let the child teach a sibling a simple 3-strand plait or weave using strips of old cloth."
                            }
                        ]
                    },
                    {
                        "name": "Performance and Display",
                        "core_competencies": ["Self-efficacy", "Communication and Collaboration"],
                        "values": ["Patriotism", "Respect"],
                        "pcis": ["Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Kenyan Folk Songs",
                                "slos": [
                                    "Sing a Kenyan folk song with correct rhythm",
                                    "Play a simple accompaniment using an improvised instrument",
                                    "Respect songs from different communities"
                                ],
                                "kiqs": ["What occasions are folk songs sung for?", "How can we make instruments from waste?"],
                                "experiences": ["Make shakers and drums", "Perform a folk song in groups"],
                                "resources": ["Drums", "Shakers"],
                                "local_materials": ["Tins with seeds as shakers", "Old jerrican drums", "Bottle top jingles"],
                                "home_activity": "Ask a grandparent to teach the child a song sung during harvest or ceremonies."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Social Studies",
                "description": "Maps, resources, governance and citizenship in Kenya and Africa.",
                "strands": [
                    {
                        "name": "Natural and Built Environments",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Digital Literacy"],
                        "values": ["Responsibility"],
                        "pcis": ["Environmental Education"],
                        "sub_strands": [
                            {
                                "name": "Map Reading: Position and Direction",
                                "slos": [
                                    "Use the 8 compass points to give directions",
                                    "Locate places on a map using a grid",
                                    "Draw a sketch map of the route from home to school"
                                ],
                                "kiqs": ["How can we tell direction without a compass?", "Why are maps useful?"],
                                "experiences": ["Use the sun to find east and west", "Draw a school compound sketch map", "Explore a digital map"],
                                "resources": ["Atlas", "Compass", "Wall map of Kenya"],
                                "local_materials": ["Stick and shadow for a sun compass", "Manila paper", "Bottle tops as map markers"],
                                "home_activity": "Walk to the market together and ask the child to describe the route using left, right and compass directions."
                            }
                        ]
                    },
                    {
                        "name": "Political Systems and Governance",
                        "core_competencies": ["Citizenship", "Communication and Collaboration"],
                        "values": ["Patriotism", "Social Justice", "Integrity"],
                        "pcis": ["Citizenship", "Good governance"],
                        "sub_strands": [
                            {
                                "name": "County Government in Kenya",
                                "slos": [
                                    "Describe the structure of the county government",
                                    "Explain services offered by the county",
                                    "Appreciate their role in public participation"
                                ],
                                "kiqs": ["What services does our county provide?", "How can citizens take part in county decisions?"],
                                "experiences": ["Mock county assembly debate", "Interview a ward administrator"],
                                "resources": ["Constitution of Kenya (simplified)", "News clips"],
                                "local_materials": ["Newspaper cuttings", "County notices"],
                                "home_activity": "Discuss a county service you use (water, health centre, market) and who is responsible for it."
                            }
                        ]
                    }
                ]
            }
        ],
        "learner": {
            "name": "Imani Chebet",
            "parent": "Daniel Kiprop",
            "progress": [
                ["Science and Technology", "EE", "Built a working circuit with a switch and explained it to the class."],
                ["Agriculture and Nutrition", "ME", "Maintains the class sack garden reliably."],
                ["Creative Arts", "ME", "Strong beadwork patterns, growing in performance confidence."],
                ["Social Studies", "AE", "Needs more practice with grid references on maps."]
            ],
            "competencies": {"Critical Thinking and Problem Solving": 4, "Digital Literacy": 3, "Creativity and Imagination": 3, "Citizenship": 2, "Learning to Learn": 3},
            "values": ["Responsibility", "Integrity", "Unity"],
            "teacher_note": "Imani shows strong scientific curiosity. Map practice at home will help with KPSEA Social Studies items."
        }
    },
    # ------------------------------------------------------------------ Grade 9
    {
        "code": "Grade 9",
        "label": "Grade 9",
        "stage": "Junior School (End)",
        "age_range": "14 to 15 years",
        "assessment": "KJSEA (Kenya Junior School Education Assessment) and Senior School pathway placement",
        "focus": "Integrated Science, Pre-Technical Studies, Social Studies and Mathematics",
        "order": 4,
        "lesson_minutes": 40,
        "daily_study_minutes": 90,
        "learner_profile": "Adolescent learner able to reason abstractly, plan projects and reflect on career interests. Works well with clear goals, peer discussion and real-world applications. Sessions of 40 to 60 minutes.",
        "areas": [
            {
                "name": "Integrated Science",
                "description": "Chemistry, physics and biology concepts applied to everyday life.",
                "strands": [
                    {
                        "name": "Mixtures, Elements and Compounds",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Learning to Learn", "Digital Literacy"],
                        "values": ["Responsibility", "Integrity"],
                        "pcis": ["Safety", "Health Education"],
                        "sub_strands": [
                            {
                                "name": "Acids, Bases and Indicators",
                                "slos": [
                                    "Prepare a plant extract indicator",
                                    "Classify household substances as acidic, basic or neutral",
                                    "Explain uses of acids and bases in daily life"
                                ],
                                "kiqs": ["Why does red cabbage juice change colour?", "How do farmers use knowledge of soil pH?"],
                                "experiences": ["Make indicator from red cabbage or flowers", "Test lemon, soap, ash water and soda"],
                                "resources": ["Test tubes", "Litmus paper", "Droppers"],
                                "local_materials": ["Red cabbage or purple flowers", "Lemon, baking soda, wood ash, bar soap", "Clear plastic cups"],
                                "home_activity": "Make a cabbage juice indicator together and test 5 kitchen items, recording results in a table."
                            }
                        ]
                    },
                    {
                        "name": "Living Things and Their Environment",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Communication and Collaboration"],
                        "values": ["Responsibility", "Love"],
                        "pcis": ["Environmental Education", "Food security"],
                        "sub_strands": [
                            {
                                "name": "Nutrition in Plants (Photosynthesis)",
                                "slos": [
                                    "Describe the process of photosynthesis",
                                    "Investigate conditions necessary for photosynthesis",
                                    "Relate photosynthesis to food security"
                                ],
                                "kiqs": ["How do plants make their own food?", "What would happen to life on Earth without green plants?"],
                                "experiences": ["Starch test on leaves kept in light and dark", "Observe leaf structure with a hand lens"],
                                "resources": ["Iodine solution", "Hand lens", "Potted plants"],
                                "local_materials": ["Bean plants in tins", "Aluminium foil or black paper", "Methylated spirit (under supervision)"],
                                "home_activity": "Cover part of a leaf on a home plant with paper for 3 days and observe the colour difference."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Pre-Technical Studies",
                "description": "Safety, drawing, materials, tools and entrepreneurship.",
                "strands": [
                    {
                        "name": "Communication in Pre-Technical Studies",
                        "core_competencies": ["Creativity and Imagination", "Communication and Collaboration"],
                        "values": ["Integrity", "Responsibility"],
                        "pcis": ["Safety"],
                        "sub_strands": [
                            {
                                "name": "Oblique Projection",
                                "slos": [
                                    "Draw objects in oblique projection",
                                    "Use correct line types and dimensions",
                                    "Appreciate drawing as a technical language"
                                ],
                                "kiqs": ["How do engineers communicate designs?", "Why is accuracy important in technical drawing?"],
                                "experiences": ["Sketch a box, stool and bookshelf in oblique", "Peer review drawings for accuracy"],
                                "resources": ["Drawing boards", "Set squares", "Rulers"],
                                "local_materials": ["Cardboard drawing boards", "Matchboxes and boxes as models", "Pencils and erasers"],
                                "home_activity": "Pick an object at home (stool, box, jerrican) and ask the young person to sketch it in oblique projection."
                            }
                        ]
                    },
                    {
                        "name": "Entrepreneurship",
                        "core_competencies": ["Creativity and Imagination", "Self-efficacy", "Critical Thinking and Problem Solving"],
                        "values": ["Integrity", "Responsibility"],
                        "pcis": ["Financial Literacy", "Youth employment"],
                        "sub_strands": [
                            {
                                "name": "Business Plan",
                                "slos": [
                                    "Identify the parts of a simple business plan",
                                    "Prepare a business plan for a school-based enterprise",
                                    "Value honesty in business"
                                ],
                                "kiqs": ["What makes a business succeed?", "How do we know if a business makes a profit?"],
                                "experiences": ["Plan a class enterprise (e.g. selling seedlings)", "Interview a local mama mboga or jua kali artisan"],
                                "resources": ["Sample business plans", "Calculators"],
                                "local_materials": ["Receipts and price lists from local shops", "Exercise book as a ledger"],
                                "home_activity": "Discuss the costs and income of a small family activity (selling eggs, milk, or vegetables) and calculate profit."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Social Studies",
                "description": "Citizenship, the Constitution and career pathways.",
                "strands": [
                    {
                        "name": "Political Developments and Governance",
                        "core_competencies": ["Citizenship", "Critical Thinking and Problem Solving"],
                        "values": ["Social Justice", "Patriotism", "Integrity"],
                        "pcis": ["Human rights", "Good governance"],
                        "sub_strands": [
                            {
                                "name": "The Constitution of Kenya: Bill of Rights",
                                "slos": [
                                    "Explain the rights of a child in the Constitution of Kenya 2010",
                                    "Relate rights to responsibilities",
                                    "Advocate for the protection of human rights"
                                ],
                                "kiqs": ["Why do rights come with responsibilities?", "How can young people protect their rights?"],
                                "experiences": ["Case study debates", "Make rights awareness posters"],
                                "resources": ["Constitution of Kenya 2010", "Case studies"],
                                "local_materials": ["Newspaper stories", "Manila paper and markers"],
                                "home_activity": "Pick a news story and discuss which right is involved and whose responsibility it is to protect it."
                            }
                        ]
                    },
                    {
                        "name": "Social Studies and Career Pathways",
                        "core_competencies": ["Self-efficacy", "Learning to Learn"],
                        "values": ["Responsibility"],
                        "pcis": ["Career guidance", "Mentorship"],
                        "sub_strands": [
                            {
                                "name": "Choosing a Senior School Pathway",
                                "slos": [
                                    "Describe the three Senior School pathways (STEM, Social Sciences, Arts and Sports Science)",
                                    "Relate personal interests and strengths to a pathway",
                                    "Make an informed pathway choice with parents and teachers"
                                ],
                                "kiqs": ["What careers fit my strengths?", "Which pathway leads to the career I want?"],
                                "experiences": ["Interest inventory", "Career day talks", "Portfolio review with a mentor"],
                                "resources": ["KICD pathway guide", "Career booklets"],
                                "local_materials": ["Portfolio folder", "Interviews with community professionals"],
                                "home_activity": "Have an evening talk about what the young person enjoys most and which careers connect to it."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Mathematics",
                "description": "Numbers, algebra, measurement, geometry and data handling.",
                "strands": [
                    {
                        "name": "Algebra",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Learning to Learn"],
                        "values": ["Integrity", "Responsibility"],
                        "pcis": ["Financial Literacy"],
                        "sub_strands": [
                            {
                                "name": "Linear Equations",
                                "slos": [
                                    "Form linear equations from real-life situations",
                                    "Solve linear equations in one and two unknowns",
                                    "Appreciate algebra as a problem-solving tool"
                                ],
                                "kiqs": ["How can we find an unknown value?", "Where do we use equations in daily life?"],
                                "experiences": ["Balance-scale model of equations", "Solve matatu fare and shopping problems"],
                                "resources": ["Graph paper", "Calculators", "Textbooks"],
                                "local_materials": ["Bottle tops as counters", "Shop price lists", "Homemade balance from a hanger"],
                                "home_activity": "Ask the young person to set up an equation to find the cost of one item when you know the total for several."
                            }
                        ]
                    },
                    {
                        "name": "Measurements",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Digital Literacy"],
                        "values": ["Integrity"],
                        "pcis": ["Financial Literacy", "Saving and investment"],
                        "sub_strands": [
                            {
                                "name": "Money: Simple and Compound Interest",
                                "slos": [
                                    "Calculate simple and compound interest",
                                    "Compare savings and loan options",
                                    "Make responsible financial decisions"
                                ],
                                "kiqs": ["Why does money grow faster with compound interest?", "Is a mobile loan expensive?"],
                                "experiences": ["Compare SACCO and bank savings", "Spreadsheet interest calculator"],
                                "resources": ["Calculators", "Bank brochures"],
                                "local_materials": ["Chama or SACCO records (with permission)", "Mobile money statements with numbers changed"],
                                "home_activity": "Work out together how much a family chama contribution grows over a year."
                            }
                        ]
                    }
                ]
            }
        ],
        "learner": {
            "name": "Kevin Mwangi",
            "parent": "Lucy Wambui",
            "progress": [
                ["Integrated Science", "ME", "Careful in experiments; strong lab report writing."],
                ["Pre-Technical Studies", "EE", "Excellent oblique drawings and a creative business plan."],
                ["Social Studies", "ME", "Thoughtful contributions in debates on rights."],
                ["Mathematics", "AE", "Solves one-step equations well; needs practice forming equations from word problems."]
            ],
            "competencies": {"Critical Thinking and Problem Solving": 3, "Creativity and Imagination": 4, "Self-efficacy": 3, "Digital Literacy": 3, "Citizenship": 3},
            "values": ["Integrity", "Responsibility"],
            "teacher_note": "Kevin shows a strong technical aptitude. Consider the STEM (Technical and Engineering) pathway; daily algebra practice is recommended before KJSEA."
        }
    },
    # ------------------------------------------------------------------ Grade 12
    {
        "code": "Grade 12",
        "label": "Grade 12",
        "stage": "Senior School (End)",
        "age_range": "17 to 18 years",
        "assessment": "End of Senior School national assessment, pathway portfolio and Community Service Learning project",
        "focus": "Senior School Pathways (STEM, Social Sciences, Arts and Sports Science) and Community Service Learning",
        "order": 5,
        "lesson_minutes": 40,
        "daily_study_minutes": 120,
        "learner_profile": "Young adult specialising in a pathway. Can work independently on research and projects, sets personal goals and is preparing for university, TVET or work. Prefers autonomy, real-world projects and career relevance.",
        "areas": [
            {
                "name": "Physics",
                "pathway": "STEM (Pure Sciences)",
                "description": "Advanced physics for the STEM pathway.",
                "strands": [
                    {
                        "name": "Electricity and Magnetism",
                        "core_competencies": ["Critical Thinking and Problem Solving", "Digital Literacy", "Learning to Learn"],
                        "values": ["Integrity", "Responsibility"],
                        "pcis": ["Safety", "Renewable energy"],
                        "sub_strands": [
                            {
                                "name": "Electromagnetic Induction",
                                "slos": [
                                    "Demonstrate electromagnetic induction",
                                    "Apply Faraday's and Lenz's laws to solve problems",
                                    "Explain how generators and transformers work in the Kenyan power grid"
                                ],
                                "kiqs": ["How is electricity generated at Olkaria or Turkwel?", "Why are transformers needed for transmission?"],
                                "experiences": ["Move a magnet through a coil connected to a galvanometer", "Build a simple bicycle dynamo demonstration"],
                                "resources": ["Coils", "Magnets", "Galvanometer"],
                                "local_materials": ["Copper wire from old motors", "Magnets from old speakers", "Bicycle dynamo"],
                                "home_activity": "Discuss the household electricity bill and where the power comes from (geothermal, hydro, wind, solar)."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Computer Science",
                "pathway": "STEM (Applied Sciences)",
                "description": "Programming, data and computational thinking.",
                "strands": [
                    {
                        "name": "Software Development",
                        "core_competencies": ["Digital Literacy", "Creativity and Imagination", "Critical Thinking and Problem Solving"],
                        "values": ["Integrity", "Responsibility"],
                        "pcis": ["Cyber security", "Online safety"],
                        "sub_strands": [
                            {
                                "name": "Algorithms and Problem Solving",
                                "slos": [
                                    "Design algorithms using pseudocode and flowcharts",
                                    "Implement and test a program that solves a community problem",
                                    "Appreciate ethics in software development"
                                ],
                                "kiqs": ["How can software solve problems in my community?", "How do we know a program is correct?"],
                                "experiences": ["Unplugged sorting activities", "Build a simple M-Pesa style transaction simulator"],
                                "resources": ["Computers", "Flowchart templates"],
                                "local_materials": ["Cards for unplugged sorting", "Smartphone with an offline coding app"],
                                "home_activity": "Ask the young person to explain, step by step, the algorithm behind sending money by mobile."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "History and Citizenship",
                "pathway": "Social Sciences",
                "description": "Kenyan and global history, constitutional development and citizenship.",
                "strands": [
                    {
                        "name": "Constitutional Development in Kenya",
                        "core_competencies": ["Citizenship", "Critical Thinking and Problem Solving", "Communication and Collaboration"],
                        "values": ["Patriotism", "Social Justice", "Peace"],
                        "pcis": ["Good governance", "Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Devolution and Public Participation",
                                "slos": [
                                    "Trace the history of devolution in Kenya",
                                    "Evaluate the successes and challenges of devolution",
                                    "Participate meaningfully in county public forums"
                                ],
                                "kiqs": ["Has devolution brought services closer to the people?", "How can youth influence county budgets?"],
                                "experiences": ["Analyse a county budget", "Attend or simulate a public participation forum"],
                                "resources": ["Constitution of Kenya 2010", "County Integrated Development Plans"],
                                "local_materials": ["County notice board announcements", "Newspaper editorials"],
                                "home_activity": "Read a news story on county development together and discuss its impact on your area."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Sports and Recreation",
                "pathway": "Arts and Sports Science",
                "description": "Performance, coaching and the science of sport.",
                "strands": [
                    {
                        "name": "Athletics",
                        "core_competencies": ["Self-efficacy", "Communication and Collaboration"],
                        "values": ["Integrity", "Unity", "Respect"],
                        "pcis": ["Anti-doping", "Health Education"],
                        "sub_strands": [
                            {
                                "name": "Middle and Long Distance Running",
                                "slos": [
                                    "Apply pacing strategies in 800m to 5000m races",
                                    "Design a 4-week endurance training programme",
                                    "Uphold clean sport and anti-doping principles"
                                ],
                                "kiqs": ["What makes Kenyan distance runners successful?", "Why is doping harmful?"],
                                "experiences": ["Time trials with split recording", "Interview a local coach"],
                                "resources": ["Stopwatch", "Track", "Training logs"],
                                "local_materials": ["Phone stopwatch", "Measured route on a murram road", "Exercise book training log"],
                                "home_activity": "Encourage an early morning run together and help record times in a training log."
                            }
                        ]
                    }
                ]
            },
            {
                "name": "Community Service Learning",
                "pathway": "Core (all pathways)",
                "description": "Applying learning to serve the community through structured projects.",
                "strands": [
                    {
                        "name": "Citizenship and Social Responsibility",
                        "core_competencies": ["Citizenship", "Communication and Collaboration", "Self-efficacy"],
                        "values": ["Love", "Responsibility", "Social Justice", "Unity"],
                        "pcis": ["Environmental Education", "Volunteerism", "Social cohesion"],
                        "sub_strands": [
                            {
                                "name": "Community Project: Planning and Implementation",
                                "slos": [
                                    "Identify a real need in the community",
                                    "Plan, implement and evaluate a community service project",
                                    "Reflect on personal growth through service"
                                ],
                                "kiqs": ["What problem in our community can we help solve?", "How will we know our project made a difference?"],
                                "experiences": ["Community needs survey", "Tree planting or clean-up drive", "Reflection journal"],
                                "resources": ["Project planning templates", "Reflection journals"],
                                "local_materials": ["Seedlings from local nurseries", "Gloves and sacks for clean-up", "Phone camera for evidence"],
                                "home_activity": "Discuss a community need you have noticed and how the family could support the young person's CSL project."
                            }
                        ]
                    }
                ]
            }
        ],
        "learner": {
            "name": "Zawadi Achieng",
            "parent": "Peter Ouma",
            "progress": [
                ["Physics", "ME", "Solid problem solving on induction; precise lab work."],
                ["Computer Science", "EE", "Built an outstanding school library app."],
                ["History and Citizenship", "ME", "Insightful essay on devolution."],
                ["Sports and Recreation", "AE", "Training log incomplete; pacing improving."],
                ["Community Service Learning", "EE", "Led a tree planting project with 300 seedlings."]
            ],
            "competencies": {"Digital Literacy": 4, "Critical Thinking and Problem Solving": 3, "Citizenship": 4, "Self-efficacy": 3, "Communication and Collaboration": 3},
            "values": ["Responsibility", "Love", "Social Justice"],
            "teacher_note": "Zawadi is ready for a STEM career. Keeping the CSL portfolio and training log up to date will strengthen the final assessment."
        }
    }
];
