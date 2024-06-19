extends VBoxContainer;



func _ready():
#	$Table.modulate = $"/root/Settings".theme["background"];
	Settings.connect("latest_leaderboard_data_ready"
					,                    self
					,"latest_leaderboard_data_ready"
					);
	pass;

func                  latest_leaderboard_data_ready()->void:
	for index in range(0,             Settings.leaderboard_number_of_entries):
		$Table.rows[index] = [
			"--",
			"--",
			"--",
			"--"
		]       ;
	for index in range(0,
				  Settings.latest_leaderboard_data.size()):
		var row = Settings.latest_leaderboard_data[index] ;
		$Table.rows[index] = [
			str((   index  + 1   ) + (Settings.leaderboard_number_of_entries * (Settings.latest_leaderboard_page - 1))),
			row["user_name"], str(row["best_score"]), "--"
		];
	var task : DatabaseTask = yield(Supabase.database.rpc("fetch_rank", { id = Settings.supabase_user.id }), "completed");
	$Table.rows[10] = [task.data["rank"], "YOU", task.data["best_score"], "--"];
	pass;

