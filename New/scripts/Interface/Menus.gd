extends Control


func _ready():
	visible = true

func _on_Pause_pressed():
	get_tree().paused = true
	$"/root/World/Interface/Control".visible = false
	$Pause.visible = false
	$ColorRect.visible = true

#In-game menu
func _on_Resume_pressed():
	close()
func _on_Checkpoint_pressed():
	close()
	$"/root/World/Player".position = G.PlayerPos
func _on_Restart_pressed():
	close()
	G.Can = false
	G.reload_scene()
func _on_Menu_pressed():
	close()
	G.scene("Main Menu")

func close():
	get_tree().paused = false
	$"/root/World/Interface/Control".visible = true
	$Pause.visible = true
	$ColorRect.visible = false


#End-level menu
func open2():
	get_tree().paused = true
	
	G.Cur_level = max(G.Cur_level, int(G.Level.substr(5)) + 1)
	
	$ColorRect2/ColorRect2/Time.text = "Time: " + str(G.Mins) + ":" + str(G.Secs)
	var level_index = int(G.Level.substr(5))
	var score = 60 * G.Mins + G.Secs
	if score < G.Scores_t[level_index]:
		G.Scores_t[level_index] = score
		$ColorRect2/ColorRect2/Best_time.visible = true
	
	$ColorRect2/ColorRect2/Deaths.text = "Deaths: " + str(G.Deaths)
	if G.Deaths < G.Scores_d[level_index]:
		G.Scores_d[level_index] = G.Deaths
		$ColorRect2/ColorRect2/Best_deaths.visible = true
	
	FS.save_data({
		"Current Level" : G.Cur_level,
		"Death scores" : G.Scores_d,
		"Time scores" : G.Scores_t
	})
	
	$"/root/World/Interface/Control".visible = false
	$Pause.visible = false
	$"/root/World/Interface/Menus/ColorRect2".visible = true

func _on_Menu2_pressed():
	close2()
	G.scene("Main Menu")
func _on_Restart2_pressed():
	close2()
	G.Can = false
	G.reload_scene()
func _on_Next2_pressed():
	close2()
	G.zero()
	G.TP = true

func close2():
	get_tree().paused = false
	$"/root/World/Interface/Control".visible = true
	$Pause.visible = true
	$ColorRect2.visible = false
	$ColorRect2/ColorRect2/Best_time.visible = true
	$ColorRect2/ColorRect2/Best_deaths.visible = true
