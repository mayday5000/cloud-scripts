#/bin/bash

read_list()
{
   local src_file=$1
   local line=""
   base_cnt=0

   while IFS= read -r line
   do
      if [[ ! "$line" = "" ]]
      then
         base_list[${base_cnt}]=$(printf '%s\n' "$line")
#         echo ${base_list[${base_cnt}]}
         base_cnt=$((base_cnt+1))
      fi
   done <"$src_file"

   if [ $base_cnt -eq 0 ]
   then
      echo "[-] Error: No se encontraron bases en el archivo: $base_list_file"
      exit 2
   fi
}

fetch_instances()
{
   gcloud compute instances list| grep RUNNING > /dev/shm/instances
   local src_file=$$1$$111
   local line=""
   base_cnt=0
   while IFS= read -r line
   do
      if [[ ! "$line" = "" ]]
      then
         base_list[${base_cnt}]=$(printf '%s\n' "$line")
#         echo ${base_list[${base_cnt}]}
         base_cnt=$((base_cnt+1))
      fi
   done <"$src_file"
   if [ $base_cnt -eq 0 ]
   then
      echo "[-] Error: No se encontraron bases en el archivo: $base_list_file"
      exit 2
   fi
}

gcloud compute instances list| grep RUNNING > /dev/shm/instances
exec 3<> /dev/shm/instances
while read str_line <&3
do
{
   echo $str_line
}
done
exec 3>&-
