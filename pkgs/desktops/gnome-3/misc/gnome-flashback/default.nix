{ stdenv
, autoreconfHook
, fetchurl
, gettext
, glib
, gnome-bluetooth
, gnome-desktop
, gnome-session
, gnome3
, gsettings-desktop-schemas
, gtk
, ibus
, intltool
, libcanberra-gtk3
, libpulseaudio
, libxkbfile
, libxml2
, metacity
, pkgconfig
, polkit
, substituteAll
, upower
, xkeyboard_config }:

let
  pname = "gnome-flashback";
  version = "3.30.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "18rwql2pi78155l9zp1i50xfi5z8xz2l08m9d81x6qqbfr1nyy57";
  };

  patches =[
    (substituteAll {
      src = ./fix-paths.patch;
      inherit metacity;
      gnomeSession = gnome-session;
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    gettext
    libxml2
    pkgconfig
  ];

  buildInputs = [
    glib
    gnome-bluetooth
    gnome-desktop
    gsettings-desktop-schemas
    gtk
    ibus
    libcanberra-gtk3
    libpulseaudio
    libxkbfile
    polkit
    upower
    xkeyboard_config
  ];

  doCheck = true;

  enableParallelBuilding = true;

  installFlags = [
    # overrides do not respect gsettingsschemasdir
    # https://gitlab.gnome.org/GNOME/gnome-flashback/issues/9
    "overridedir=${placeholder "out"}/share/gsettings-schemas/${name}/glib-2.0/schemas"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    description = "GNOME 2.x-like session for GNOME 3";
    homepage = https://wiki.gnome.org/Projects/GnomeFlashback;
    license = licenses.gpl2;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
