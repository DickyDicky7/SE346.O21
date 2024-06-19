extends Node;

signal start_game;
signal a         ;

var sound_buttons = {true: preload("res://assets/GameIcons/PNG/White/2x/audioOn.png"),
					false: preload("res://assets/GameIcons/PNG/White/2x/audioOff.png")};
var music_buttons = {true: preload("res://assets/GameIcons/PNG/White/2x/musicOn.png"),
					false: preload("res://assets/GameIcons/PNG/White/2x/musicOff.png")};

var current_screen = null;

func _ready():
	 register_buttons(); change_screen($TitleScreen);
	
func register_buttons():
	var buttons = get_tree().get_nodes_in_group(
	   "buttons");
	for button in buttons:
		button.connect("pressed", self,
			"_on_button_pressed",
				[button]);
		match    button.name:
			"Ads":
				if not Engine.has_singleton("AdMob"):
					button.hide();
				if Settings.enable_ads:
					button.text = "Disable Ads";
				else:
					button.text = "!Enable Ads";
			"Sound":
				button.texture_normal = sound_buttons[Settings.enable_sound];
			"Music":
				button.texture_normal = music_buttons[Settings.enable_music];

func _on_button_pressed(button):
	if Settings.enable_sound:
		$Click .play();
	match button.name :
		"About":
			change_screen($AboutScreen);
		"Ads":
			Settings.enable_ads = !Settings.enable_ads;
			if                     Settings.enable_ads:
				button.text = "Disable Ads";
			else:
				button.text = "!Enable Ads";
		"Home":
			change_screen($TitleScreen);
		"Play":
			playing_mode = PLAYING_MODE.SINGLE;
			change_screen(null);
			yield(get_tree().create_timer(0.5), "timeout"); emit_signal("start_game");
		"Settings":
			change_screen($SettingsScreen);
		"Sound":
			Settings. enable_sound  =              !Settings.enable_sound ;
			button  .texture_normal = sound_buttons[Settings.enable_sound];
			Settings.save_settings();
		"Music":
			Settings. enable_music  =              !Settings.enable_music ;
			button  .texture_normal = music_buttons[Settings.enable_music];
			Settings.save_settings();
		"PlayMult":
			playing_mode = PLAYING_MODE.MULTI_;
			change_screen($LobbyScreen);
			
		"HostButton":
			print(button.name);
			
			var peer = NetworkedMultiplayerENet.new()
			peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
			var err = peer.create_server(8910, 2) # Maximum of 1 peer, since it's a 2-player game.
			if err != OK:
		# Is another server running?
				print(err)
				return
			get_tree().set_network_peer(peer)
#			print(peer);
						
		"JoinButton":
			print(button.name);
			
			var ip = $LobbyScreen/MarginContainer/VBoxContainer/Panel/Address.get_text()
			if not ip.is_valid_ip_address():
				print("IP address is invalid")
				return

			var peer = NetworkedMultiplayerENet.new()
			peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
			peer.create_client(ip, 8910)
			get_tree().set_network_peer(peer)

	
			
		"FindPublicIP":
			
			OS.shell_open("https://icanhazip.com/");
		
		"SignOut":
			change_screen($TitleScreen);
			Supabase.auth.sign_out(   );
		"Leaderboard":
			change_screen($LeaderboardScreen);
			Settings.fetch_latest_leaderboard_data();
		"NextLeaderboardPage":
			Settings.latest_leaderboard_page += 1;
			$LeaderboardScreen/MarginContainer/VBoxContainer/Label/VBoxContainer/HBoxContainer2/Page.text = str(Settings.latest_leaderboard_page);
			Settings.fetch_latest_leaderboard_data();
		"PrevLeaderboardPage":
			Settings.latest_leaderboard_page -= 1;
			if (Settings.latest_leaderboard_page <= 0):
				Settings.latest_leaderboard_page  = 1 ;
			$LeaderboardScreen/MarginContainer/VBoxContainer/Label/VBoxContainer/HBoxContainer2/Page.text = str(Settings.latest_leaderboard_page);
			Settings.fetch_latest_leaderboard_data();

func change_screen(new_screen):
	if  current_screen:
		current_screen.disappear();
		yield(current_screen.tween, "tween_completed");
	current_screen=new_screen ;
	if      new_screen:
		current_screen.   appear();
		yield(current_screen.tween, "tween_completed");

func game_over(score, highscore):
	var        score_box = $GameOverScreen/MarginContainer/VBoxContainer/Scores;
	score_box.get_node("Score").text = "Score: %s" %     score;
	score_box.get_node("Best!").text = "Best*: %s" % highscore;
	change_screen        ( $GameOverScreen );

enum PLAYING_MODE { SINGLE , MULTI_ };
var  playing_mode                    ;









