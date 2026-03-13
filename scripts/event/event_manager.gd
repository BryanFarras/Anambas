# event_manager.gd (Autoload)
extends Node

var is_processing_event: bool = false

func run_event_sequence(commands: Array[EventCommand]) -> void:
    if is_processing_event:
        return
        
    is_processing_event = true
    
    # Lock player movement using your existing PlayerManager logic
    var player = PlayerManager.get_player()
    if player:
        player.is_interacting = true

    # Execute commands sequentially
    for command in commands:
        await command.execute()

    # Release player lock when all commands finish
    if player:
        player.is_interacting = false
        
    is_processing_event = false