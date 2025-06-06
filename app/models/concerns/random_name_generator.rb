module RandomNameGenerator
  extend ActiveSupport::Concern

  ADJECTIVES = %w[
    Abundant Accessible Accurate Active Adaptable Adorable Adventurous Affectionate
    Alert Alive Amazing Ambitious Amiable Amusing Ancient Angry Annoyed Anxious
    Articulate Artistic Ashamed Assertive Attentive Attractive Beautiful Bewildered
    Big Bitter Boisterous Bold Brave Bright Broad Broken Busy Calm Careful
    Careless Caring Cautious Charming Cheerful Clean Clear Clever Close Cloudy
    Clumsy Cold Colorful Comfortable Comic Concerned Condemned Confused Cool
    Cooperative Courageous Crazy Creepy Crooked Curious Cute Dangerous Dark Dead
    Defiant Delightful Determined Different Difficult Disgusted Distinct Disturbed
    Dizzy Doubtful Drab Dull Eager Easy Ecstatic Elated Elegant Embarrassed Empty
    Encouraging Energetic Enormous Enthusiastic Envious Evil Excited Expensive
    Exuberant Fair Faithful Famous Fancy Fantastic Fast Fierce Filthy Fine
    Foolish Fragile Frail Free Frequent Fresh Friendly Frightened Funny Gentle
    Gifted Glamorous Gleaming Good Graceful Grateful Great Greedy Green Grieving
    Grotesque Grumpy Handsome Happy Hard Healthy Heavy Helpful Hilarious Historical
    Horrible Hungry Hurt Icy Ill Important Impossible Inexpensive Innocent
    Itchy Jealous Jolly Joyous Kind Large Late Lazy Light Lively Lonely Long
    Loose Lovely Lucky Magnificent Massive Mature Mean Misty Modern Motionless
    Muddy Mushy Mysterious Narrow Nasty Naughty Nervous Nice Noisy Nutty Obedient
    Obnoxious Odd Old Orange Ordinary Outrageous Outstanding Panicky Perfect Plain
    Pleasant Poised Poor Powerful Precious Prickly Proud Puzzled Quaint Quick
    Quiet Rapid Real Rebel Red Relieved Repulsive Rich Rough Round Sad Safe
    Scary Selfish Shiny Short Shy Silly Simple Sleepy Small Smart Smooth Soft
    Sparkling Splendid Spotless Square Steep Strange Strong Stunning Stupid Super
    Swift Talented Tall Tame Tan Tender Tense Terrible Thankful Thoughtful Tiny
    Tired Tough Troubled Ugliest Uglier Ugly Uninterested Unsightly Unusual Upset
    Uptight Vast Victorious Vivacious Wandering Weary Wide Wild Witty Worried
    Wrong Young Zealous
  ].freeze

  ANIMALS = %w[
    Aardvark Albatross Alligator Alpaca Ant Anteater Antelope Ape Armadillo
    Donkey Baboon Badger Barracuda Bat Bear Beaver Bee Bison Boar Buffalo
    Butterfly Camel Capybara Caribou Cassowary Cat Caterpillar Cattle Chamois
    Cheetah Chicken Chimpanzee Chinchilla Chough Clam Cobra Cockroach Cod
    Cormorant Coyote Crab Crane Crocodile Crow Curlew Deer Dinosaur Dog
    Dogfish Dolphin Dotterel Dove Dragonfly Duck Dugong Eagle Echidna Eel
    Eland Elephant Elk Emu Falcon Ferret Finch Fish Flamingo Fly Fox Frog
    Gaur Gazelle Gerbil Giraffe Gnat Gnu Goat Goldfinch Goldfish Goose
    Gorilla Goshawk Grasshopper Grouse Guinea Gull Hamster Hare Hawk Hedgehog
    Heron Herring Hippopotamus Hornet Horse Human Hummingbird Hyena Ibex Ibis
    Jackal Jaguar Jay Jellyfish Kangaroo Kingfisher Koala Kookabura Kouprey
    Kudu Lapwing Lark Lemur Leopard Lion Llama Lobster Locust Loris Louse
    Lyrebird Magpie Mallard Manatee Mandrill Mantis Marten Meerkat Mink Mole
    Mongoose Monkey Moose Mosquito Mouse Mule Narwhal Newt Nightingale Octopus
    Okapi Opossum Oryx Ostrich Otter Owl Oyster Panther Parrot Partridge
    Peafowl Pelican Penguin Pheasant Pig Pigeon Pony Porcupine Porpoise Quail
    Quelea Quetzal Rabbit Raccoon Rail Ram Rat Raven Reindeer Rhinoceros Robin
    Salamander Salmon Sand Sardine Scorpion Seahorse Seal Shark Sheep Shrew
    Skunk Snail Snake Sparrow Spider Spoonbill Squid Squirrel Starling Stingray
    Stinkbug Stork Swallow Swan Tapir Tarsier Termite Tiger Toad Trout Turkey
    Turtle Viper Vulture Wallaby Walrus Wasp Weasel Whale Wildcat Wolf
    Wolverine Wombat Woodcock Woodpecker Worm Wren Yak Zebra
  ].freeze

  module_function

  def generate
    "#{ADJECTIVES.sample} #{ANIMALS.sample} #{rand(100..999)}"
  end
end
