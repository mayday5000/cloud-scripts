#/bin/bash

unset instance_list
unset zone_list
_default_zone=us-central1-c


ayuda()
{
   echo 
   echo "Ayuda:"
   echo
   echo $0 [user] [instance] src_file [dst_file] [zone]
   echo
}


show_instances()
{
   printf "\n[*] Instancias:\n\n"
   gcloud compute instances list
}


get_instance()
{
   cnt_inst=0
   for ((i=0; i<$cnt_inst; i++)); do
      if [[ "${instance_list[${i}]}" = "$_instance" ]]
      then
         cnt_inst=$((cnt_inst+1))
      fi
   done

   if [ $cnt_inst -eq 0 ]
   then
      echo "[-] Error: La instancia especificada no esta corriendo.\n"
      exit 2
   fi
}


get_zone()
{
   cnt_zone=0
   for ((i=0; i<$cnt_inst; i++)); do
      if [[ "${instance_list[${i}]}" = "$_instance" ]]
      then
         _zone="${zone_list[${i}]}"
         cnt_zone=$((cnt_zone+1))
      fi
   done

   if [ $cnt_zone -eq 0 ]
   then
      echo "[-] Error: No se encontro zona para la instancia especificada.\n"
      exit 2
   fi
}


valid_args()
{
   _user=$1
   _instance=$2
   _src_path=$3
   _dst_path=$4
   _zone=$5
   _num_inst=0
   _num_zone=0

   if [[ $_instance = "" ]]
   then
      if [ $cnt_inst -gt 0 ]
      then
         _instance="${instance_list[${_num_inst}]}"
      fi
   else
      get_instance
   fi

   if [[ $_zone = "" ]]
   then
      if [ $cnt_inst -gt 0 ]
      then
         _zone="${zone_list[${_num_zone}]}"
      fi
   fi

   if [ ! -f "$_src_path" ]
   then
      echo "[-] Error: archivo de origen: $_src_path no existe."
      ayuda
      exit 2
   fi

   if [[ $_dst_path = "" ]]
   then
      _dst_path="~/""$_src_path"
   fi
}


fetch_instances()
{
   gcloud compute instances list| grep RUNNING > /dev/shm/instances
   local src_file=/dev/shm/instances
   local line=""
   cnt_inst=0

   while IFS= read -r line
   do
      if [[ ! "$line" = "" ]]
      then
         instance_list[${cnt_inst}]=$(printf '%s\n' "$line")|awk '{print $1;}'
         zone_list[${cnt_inst}]=$(printf '%s\n' "$line")|awk '{print $2;}'
         cnt_inst=$((cnt_inst+1))
      fi
   done <"$src_file"
   
   if [ $cnt_inst -eq 0 ]
   then
      echo "[-] $cnt_inst Instancias activas corriendo.\n"
      show_instances
      exit 2
   else
      echo "[+] $cnt_inst Instancia/s activas corriendo...\n"
   fi
}



call_gcloud()
{
   printf "[*] Copiando archivo...\n"
   gcloud compute scp $_src_path $_user@$_instance:$_dst_path --zone $_zone
}


fetch_instances
valid_args $1 $2 $3 $4 $5
call_gcloud



