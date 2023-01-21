#!/usr/bin/env bash

declare -A AFs
 	AFs['ext4']='Linux Ext4'
   AFs['btrfs']='Oracle Btrfs'
   AFs['ext2']='Linux Ext2'
   AFs['ext3']='Linux Ext3'
   AFs['jfs']='Linux Jfs'
   AFs['reiserfs']='Linux Reiserfs'
   AFs['f2fs']='Flash-Friendly Filesystem'
   AFs['xfs']="SGI's Xfs"

echo ${AFs['jfs']}

for i in "${!AFs[@]}"; do
	echo $i
done



