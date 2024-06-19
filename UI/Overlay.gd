extends Control;

func _ready():
	Supabase.auth.connect("signed_out"
						 , self
						 ,"signed_out"
						 );
	pass;

func _on_Auth_signed_in (user : SupabaseUser):
	hide();
	Settings .  supabase_user =         user ;
	pass  ;

func          signed_out(                   ):
	show();
	pass  ;



