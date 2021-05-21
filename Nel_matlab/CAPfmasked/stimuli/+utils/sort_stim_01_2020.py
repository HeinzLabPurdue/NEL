import os
import shutil

#print(os.listdir('./'))


dic_folders={
	'0-nomasker-broadbandnoise':['0-broadbandx3'],
	'1-firstscan-notch-noises':['1-notch_first_scan_CFs_attns'],   #add broadband?
	'2-narrobandanalysis-hp-lp':['9-hp-narrowbandanalysis', '10-lp-narrowbandanalysis'],
	'3-around1500':['23-2bands1500',  '17-narrorband1500', '2-notch1500_bw1000', '11-notch1500-variousbandwidths'],
	'4-around2200':[ '12-notch2200-variousbandwidths', '24-2bands2200', '18-narrowband2200', '3-notch2200_bw1500',],
	'5-around3000':['25-2bands3000', '4-notch3000_bw1500', '19-narrowband3000', '13-notch3000-variousbandwidths'],
	'6-around4000':['26-2bands4000', '5-notch4000_bw1700','14-notch4000-variousbandwidths', '20-narrowband4000'],
	'7-around5000':['27-2bands5000', '21-narrowband5000', '15-notch5000-variousbandwidths', '6-notch5000_bw2000'],
	'8-around6000':['22-narrowband6000', '16-notch6000-variousbandwidths',  '7-notch6000_bw2000',  '28-2bands6000'],
	'9-around8000':['8-notch8000_bw2300'],
	'10-complexes':[ '29-complexes']
}

new_folder='newstim'
os.makedirs(new_folder)

for folder, old_folders in dic_folders.items():
	os.makedirs(f'{new_folder}/{folder}/')
	for old_folder in old_folders:
		for old_file in os.listdir(old_folder):
			shutil.copy(f'./{old_folder}/{old_file}', f'./{new_folder}/{folder}/{old_file}')
