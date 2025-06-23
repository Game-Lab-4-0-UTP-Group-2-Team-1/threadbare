# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
@tool
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D


func _hide() -> void:
	animated_sprite_2d.play(&"hide")
	await animated_sprite_2d.animation_finished
	if animated_sprite_2d.animation == &"hide":
		animated_sprite_2d.visible = false


func _reveal() -> void:
	animated_sprite_2d.visible = true
	animated_sprite_2d.play(&"reveal")
	await animated_sprite_2d.animation_finished
	if animated_sprite_2d.animation == &"reveal":
		animated_sprite_2d.play(&"idle")


func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_hide()


func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_reveal()
