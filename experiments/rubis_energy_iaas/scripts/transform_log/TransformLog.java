import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;


public class TransformLog {

	@SuppressWarnings("unused")
	public static void main(String[] args){
		if (args.length != 4){
			System.err.println("Requiert ' arguments : chemins vers fichier date.log, \n" +
					" chemin vers state_plateforme.log \n" +
					"nb_vm initial" +
					"level_appli_initial");
			System.exit(1);
		}
		
		String file_datelog = args[0];
		String file_state_plateforme= args[1];
		String nb_vm_initial=args[2];
		String level_appli_initial=args[3];
		 
		try{
		
			BufferedReader buff_file_datelog = new BufferedReader(new FileReader(file_datelog));
			BufferedReader buff_file_state_plateforme = new BufferedReader(new FileReader(file_state_plateforme));
		 
			try {
				String line_file_logsdat="";
				long date_depart_seconde=-1;
				int cpt_entrant=0;
				int	cpt_sortant_ok=0;
				int	cpt_sortant_ko=0;
				int sum_rt=0;
				int	cpt_rt=0;
				
				long date_debut=0;
				
				long date_state_log=0;
				String nb_vm=nb_vm_initial;
				String level_appli=level_appli_initial;
				
				long date_state_log_suivant;
				String nb_vm_suivant;
				String level_appli_suivant;
				
				String line_file_state_plateforme=buff_file_state_plateforme.readLine();
				String tmp [] =line_file_state_plateforme.split(" ");
				date_state_log_suivant=Long.parseLong(tmp[0]);
				nb_vm_suivant=tmp[1];
				level_appli_suivant=tmp[2];
								
				
				Map<String,Long> begin = new HashMap<String,Long>();
				
				while ((line_file_logsdat= buff_file_datelog.readLine()) != null) {
					//date id_req final_state type
					tmp =line_file_logsdat.split(" ");
					
				
					long date = Long.parseLong(tmp[0]);
					String id_req = tmp[1];
					String final_state = tmp[2];
					String type = tmp[3];
					
					
					if(date_depart_seconde==-1){
						date_depart_seconde=date;
						date_debut=date;
					}
					if(date >= date_depart_seconde + 1000){
						if(date >= date_state_log_suivant){
							date_state_log=date_state_log_suivant;
							nb_vm= nb_vm_suivant;
							level_appli = level_appli_suivant;
							
							line_file_state_plateforme=buff_file_state_plateforme.readLine();
							if(line_file_state_plateforme != null){
								String tmp2 [] =line_file_state_plateforme.split(" ");
								date_state_log_suivant=Long.parseLong(tmp2[0]);
								nb_vm_suivant=tmp2[1];
								level_appli_suivant=tmp2[2];
							}
						}
						System.out.println(((double)(date_depart_seconde - date_debut)/1.0)+" "+cpt_entrant+" "+cpt_sortant_ok+" "+cpt_sortant_ko+" "+nb_vm+" "+level_appli+" "+((double)sum_rt)/((double) cpt_rt));
						date_depart_seconde=date;
						cpt_entrant=0;
						cpt_sortant_ok=0;
						cpt_sortant_ko=0;
						sum_rt=0;
						cpt_rt=0;
					}
					if(type.equals("D")){
						cpt_entrant++;
						begin.put(id_req, new Long(date));
					}else if (type.equals("F")){
						if (final_state.equals("KO")){
							cpt_sortant_ko++;
						}else{
							cpt_sortant_ok++;
							Long date_begin_request=begin.get(id_req);
							long latence=date - date_begin_request.longValue();
							sum_rt += latence;
							cpt_rt ++;
						}
					}else{
						System.err.println("Error");
						System.exit(2);
					}			
					
				}
				
				
				
			} finally {
				// dans tous les cas, on ferme nos flux
				buff_file_datelog.close();
				buff_file_state_plateforme.close();
			}
		} catch (IOException ioe) {
			// erreur de fermeture des flux
			System.out.println("Erreur --" + ioe.toString());
		}
		
	}
}
