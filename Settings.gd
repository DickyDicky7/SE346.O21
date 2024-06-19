extends Node;

var score_file = "user://clicking_jump_v1_0_0_highscore.save"; var settings_file = "user://clicking_jump_v1_0_0_settings.save";
var enable_sound = true;
var enable_music = true;
var latest_theme =      1;

var circles_per_level = 5;

var color_schemes = {
	"NEON1": {
		'background'    : Color8(058, 043, 059),
		'player_body'   : Color8(235, 141, 156),
		'player_trail'  : Color8(255, 216, 186),
		'circle_fill'   : Color8(045, 074, 084), 
		'circle_static' : Color8(188, 074, 155),
		'circle_limited': Color8(012, 116, 117),
	},
	"NEON2": {
		'background'    : Color8(029, 020, 044),
		'player_body'   : Color8(125, 192, 211),
		'player_trail'  : Color8(201, 243, 255),
		'circle_fill'   : Color8(036, 024, 075),
		'circle_static' : Color8(103, 130, 185),
		'circle_limited': Color8(071, 056, 145),
	},
	"NEON3": {
		'background'    : Color8(042, 023, 059),
		'player_body'   : Color8(105, 128, 158),
		'player_trail'  : Color8(149, 197, 172),
		'circle_fill'   : Color8(063, 044, 095),
		'circle_static' : Color8(076, 092, 135),
		'circle_limited': Color8(068, 063, 123),
	},
	"NEON4": {
		'background'    : Color8(050, 083, 095),
		'player_body'   : Color8(014, 175, 155),
		'player_trail'  : Color8(048, 225, 185),
		'circle_fill'   : Color8(065, 029, 049),
		'circle_static' : Color8(011, 138, 143),
		'circle_limited': Color8(099, 027, 052),
	},
	"NEON5": {
		'background'    : Color8(070, 066, 094),
		'player_body'   : Color8(255, 105, 115),
		'player_trail'  : Color8(255, 176, 163),
		'circle_fill'   : Color8(021, 120, 140),
		'circle_static' : Color8(255, 238, 204),
		'circle_limited': Color8(000, 185, 190),
	}
};

var theme = color_schemes["NEON1"];

var supabase_user  :  SupabaseUser;
var thread : Thread;
var        leaderboard_number_of_entries : int = 10;
var        latest_leaderboard_page       : int = 01;
var        latest_leaderboard_data =  []           ;
signal     latest_leaderboard_data_ready           ;
func fetch_latest_leaderboard_data_on_thread()  ->  void:
		   var task : DatabaseTask = yield(Supabase.database.rpc("fetch_top_leaderboard" , { page = latest_leaderboard_page , number = leaderboard_number_of_entries }) , "completed");
		   latest_leaderboard_data = task.data     ;                                          if  ( latest_leaderboard_data == null ):                latest_leaderboard_data = [    ];
		   emit_signal                    (
		  "latest_leaderboard_data_ready" )        ;
		   pass                                    ;
func fetch_latest_leaderboard_data          ()  ->  void:
		   thread = Thread.new();
		   thread.start(self    ,
	"fetch_latest_leaderboard_data_on_thread");
		   pass  ;

static func rand_weighted(weights):
	var sum  = 0;
	for weight in weights:
		sum +=    weight ;
	var num  = rand_range(0, sum);
	for i in      weights.size():
		if num <  weights[i]:
			return i;
		num -=    weights[i];
		
#var admob = null;
#var   real_ads = false;
#var banner_top = false;
## Fill these from your AdMob account:
#var ad_banner_id = "";
#var ad_interstitial_id = "";
var enable_ads = true setget set_enable_ads;
var interstitial_rate =  0.2;

func latest_leaderboard_data_ready():
	thread.wait_to_finish();
	pass;

func _ready():
	load_settings();
	if (latest_theme == null):
		latest_theme =  1    ;
	if (latest_theme >= 6   ):
		latest_theme =  1    ;
	theme = color_schemes["NEON" + str(latest_theme)]; latest_theme += 1;
	save_settings();
	self.connect("latest_leaderboard_data_ready"
,   self
,                "latest_leaderboard_data_ready"
				);
#	if          Engine.has_singleton("AdMob"):
#		admob = Engine.get_singleton("AdMob");
#		admob.initWithContentRating(real_ads, get_instance_id(), true, false, "G");
#		admob.loadBanner      (ad_banner_id ,       banner_top);
#		admob.loadInterstitial(ad_interstitial_id);
		
#func show_ad_banner():
#	if  admob and enable_ads:
#		admob.showBanner()  ;
#
#func hide_ad_banner():
#	if  admob:
#		admob.hideBanner()  ;
#
#func show_ad_interstitial():
#	if      admob and enable_ads:
#		if randf() <  interstitial_rate:
#			admob.showInterstitial();
#		else:
#			show_ad_banner();
#
#func _on_interstitial_close():
#	if    admob and enable_ads:
#		show_ad_banner();
		
func set_enable_ads(value):
	 enable_ads   = value ;
#	if enable_ads:
#		admob.show_banner();
#	if !enable_ads:
#		admob.hide_banner();
	 save_settings  ();
		
func save_settings  ():
	var f = File.new();
	f.open(settings_file, File.WRITE);
	f.store_var(enable_sound);
	f.store_var(enable_music);
	f.store_var(enable_ads);
	f.store_var(latest_theme);
	f.close();
	
func load_settings  ():
	var f = File.new();
	if f.file_exists(settings_file):
		f.open(settings_file, File.READ);
		enable_sound = f.get_var();
		enable_music = f.get_var();
		self.enable_ads = f.get_var();
		latest_theme = f.get_var();
		f.close();


