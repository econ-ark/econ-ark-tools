# Timeshift

The Econ-ARK machine configures itself to perform automatic backups using a tool called `timeshift`.  This is a general-purpose backup tool that works on any linux machine.

Timeshift automatically makes periodic complete backups -- in the sense that you can use timeshift itself to restore the machine to the state it was in as of any particular `snapshot`. 

This is a particularly useful tool when it comes to doing system upgrades, or installing something that you think might break other things. You can install, then see if everything works, and if not restore the snapshot you made immediately before installing the new tool.

For more info about how it works, see the [timeshift webpage](https://teejeetech.com/timeshift/).

You can even use timeshift to migrate your installation from one drive (or partition) to another.

Steps (for a machine without `/home` on a standalone partition)
* Install a bootable linux system on the target device (drive, stick, ...)
    * Put all the linux system files inside the root partition (called `/`)
	  * make note of the partition location (like, `/dev/sda3`
	* Make sure there is a small `junk` partition on a third device
* Make a timeshift backup of the machine you want to migrate (machine A)
   * make a note of the root partition's location (like, maybe, `/dev/sdb3`)
* On machine A
   * run timeshift 
   * select the `Restore` button
   * choose the latest snapshot
   * select the target device for the root partition
      * In our example, `/dev/sda3`
   * for all the other items, choose to restore them to the `junk` partition
	 * select the option to rebuild grub and update `initramfs`
 
 You are now ready to execute the migrate/restore. Do it!
 
When this process finishes, you should be able to boot the target device containing a snapshot of machine A as it was when you did the backup.
