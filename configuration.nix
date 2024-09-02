# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

######################## QEMU ###################################
virtualisation.libvirtd.enable = true;
programs.virt-manager.enable = true;

######################### Nvidia ##################################
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

  # 550 was crashing on wayland.
  # Special config to load the latest (535 or 550) driver for the support of the 4070 SUPER
  hardware.nvidia.package = let 
  rcu_patch = pkgs.fetchpatch {
    url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
    hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
  };
  in config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "535.154.05";
    sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
    sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
    openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
    settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
    persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";

    #version = "550.40.07";
    #sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
    #sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
    #openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
    #settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
    #persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

    patches = [ rcu_patch ];
 };


  hardware.nvidia.prime = {
    # Offload: Offload mode puts your Nvidia GPU to sleep and lets the Intel GPU handle all tasks
    offload = {
      enable = false;
      enableOffloadCmd = false;
    };

    # Sync: Enabling PRIME sync introduces better performance and greatly reduces screen tearing
     sync.enable = true;

    intelBusId = "PCI:0:0:2";
    nvidiaBusId = "PCI:0:1:0";
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  ####################################################################

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Needed for Audio
  boot.kernelParams = [ "snd-intel-dspcfg.dsp_driver=1" ];

  # Dual Booting with Windows 11
 # boot.loader.grub.enable = true;
 # boot.loader.grub.device = "nodev";
 # boot.loader.grub.useOSProber = true;

  boot.initrd.luks.devices."luks-c1d5c17c-5e88-453e-a33f-57d9cf319cd0".device = "/dev/disk/by-uuid/c1d5c17c-5e88-453e-a33f-57d9cf319cd0";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable Mullvad service
  services.mullvad-vpn.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # LightDM display manager
  #services.xserver.displayManager.lightdm.enable=true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # No Audio?
  sound.enable = true;
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;
  nixpkgs.config.pulseaudio = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  services.pipewire.enable = false;
  # We need this to be disabled for some reason fpr pulseaudio?
  services.gnome.gnome-remote-desktop.enable = false;

  # Enable sound with pipewire.
  #hardware.pulseaudio.enable = false;
  #security.rtkit.enable = true;
  #services.pipewire = {
    #enable = true;
    #alsa.enable = true;
    #alsa.support32Bit = true;
    #pulse.enable = false;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
   #};

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.based = {
    isNormalUser = true;
    description = "based";
    extraGroups = [ "networkmanager" "wheel" "audio" "sound" "video" "libvirtd"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  programs.bash.shellAliases = {
	neofetch = "fastfetch";
        editconf = "sudo nano /etc/nixos/configuration.nix";
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  fonts.packages = with pkgs; [
  	(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono""0xProto" ]; })
  ];

  # Hyperland
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };

   xdg.portal.enable = true;
   #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


  # Virtual Box
   virtualisation.virtualbox.host.enable = true;
   virtualisation.virtualbox.host.enableKvm = false;
   virtualisation.virtualbox.guest.clipboard = true;
   virtualisation.virtualbox.guest.enable = true;
   users.extraGroups.vboxusers.members = [ "based" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        pkgs.wget
	pkgs.neovim
	pkgs.btop
	pkgs.fastfetch
	pkgs.mullvad-vpn
	pkgs.mullvad-browser
	#pkgs.gnome-console
	pkgs.tilix
	pkgs.kitty
	pkgs.git	
	pkgs.nerdfonts
	pkgs.discord
	pkgs.qbittorrent
	pkgs.obsidian
	pkgs.wofi
	pkgs.libsForQt5.dolphin
	#pkgs.virtualbox
	pkgs.linuxKernel.packages.linux_xanmod_stable.virtualbox

        # System Packages
        #pkgs.pipewire
	libgcc
	pkgs.rPackages.pcutils
	pkgs.lshw
	pkgs.python3
	pkgs.go
	#pkgs.gcc
	#pkgs.gcc-toolchain
	#pkgs.clang
	pkgs.libreoffice
        pkgs.qemu
        
	# Lightdm instead of GDM for display manager
	#pkgs.lightdm

	# Additional Hyperland
	waybar
	dunst
	libnotify
	rofi-wayland
	swww

	#Gnome Extensions
	pkgs.gnome.gnome-tweaks
	pkgs.gnome.gnome-shell-extensions
	pkgs.gnomeExtensions.blur-my-shell
	pkgs.gnomeExtensions.pop-shell
	#pkgs.gnomeExtensions.mullvad-indicator
	pkgs.gnomeExtensions.vitals

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

