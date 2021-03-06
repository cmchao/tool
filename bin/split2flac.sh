#!/bin/sh
# Copyright (c) 2009-2010 Serge "ftrvxmtrx" Ziryukin
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Dependencies:
#          shntool, cuetools
# SPLIT:   flac, wavpack, mac
# CONVERT: flac, faac, libmp4v2, id3lib, lame, vorbis-tools
# ART:     ImageMagick
# CHARSET: iconv
# GAIN:    flac, aacgain, mp3gain, vorbisgain

# Exit codes:
# 0 - success
# 1 - error in arguments
# 2 - file or path is not accessible
# 3 - something has failed

CONFIG="${HOME}/.split2flac"
TMPCUE="${HOME}/.split2flac_sheet.cue"
TMPPIC="${HOME}/.split2flac_cover.jpg"
FAILED="split_failed.txt"

NOSUBDIRS=0
NOPIC=0
REMOVE=0
NOCOLORS=0
PIC_SIZE="192x192"
REPLAY_GAIN=0
FORMAT="${0##*split2}"
FORMAT="${FORMAT%.sh}"
DIR="."
OUTPATTERN="@artist/{@year - }@album/@track - @title.@ext"

# codecs default arguments
ENCARGS_flac="-8"
ENCARGS_m4a="-q 500"
ENCARGS_mp3="--preset extreme"
ENCARGS_ogg="-q 10"
ENCARGS_wav=""

# load settings
eval $(cat "${CONFIG}" 2>/dev/null)
DRY=0
SAVE=0
NASK=0
unset PIC INPATH CUE CHARSET
FORCE=0

# do not forget to update before commit
VERSION=hg-rev82

HELP="\${cG}split2flac version: ${VERSION}
Splits one big \${cU}APE/FLAC/WV/WAV\$cZ\$cG audio image (or a collection) into \${cU}FLAC/M4A/MP3/OGG_VORBIS/WAV\$cZ\$cG tracks with tagging and renaming.

Usage: \${cZ}split2\${FORMAT}.sh [\${cU}OPTIONS\$cZ] \${cU}FILE\$cZ [\${cU}OPTIONS\$cZ]\$cZ
       \${cZ}split2\${FORMAT}.sh [\${cU}OPTIONS\$cZ] \${cU}DIR\$cZ  [\${cU}OPTIONS\$cZ]\$cZ
         \$cG-p\$cZ                    - dry run
         \$cG-o \${cU}DIRECTORY\$cZ        \$cR*\$cZ - set output directory (current is \$cP\${DIR}\$cZ)
         \$cG-of \${cU}'PATTERN'\$cZ       \$cR*\$cZ - use specific output naming pattern (current is \$cP'\${OUTPATTERN}'\$cZ)
         \$cG-cue \${cU}FILE\$cZ             - use file as a cue sheet (does not work with \${cU}DIR\$cZ)
         \$cG-cuecharset \${cU}CHARSET\$cZ   - convert cue sheet from CHARSET to UTF-8 (no conversion by default)
         \$cG-nask\$cZ                 - do not ask to enter proper charset of a cue sheet (default is to ask)
         \$cG-f \${cU}FORMAT\$cZ             - use specific output format (current is \$cP\${FORMAT}\$cZ)
         \$cG-e \${cU}'ARG1 ARG2'\$cZ      \$cR*\$cZ - encoder arguments (current is \$cP'\${ENCARGS}'\$cZ)
         \$cG-eh\$cZ                   - show help for current encoder and exit\$cZ
         \$cG-c \${cU}FILE\$cZ             \$cR*\$cZ - use file as a cover image (does not work with \${cU}DIR\$cZ)
         \$cG-nc                 \${cR}*\$cZ - do not set any cover images
         \$cG-cs \${cU}WxH\$cZ             \$cR*\$cZ - set cover image size (current is \$cP\${PIC_SIZE}\$cZ)
         \$cG-d                  \$cR*\$cZ - create artist/album subdirs (default)
         \$cG-nd                 \$cR*\$cZ - do not create any subdirs
         \$cG-D                  \$cR*\$cZ - delete original file
         \$cG-nD                 \$cR*\$cZ - do not remove the original (default)
         \$cG-F\$cZ                    - force deletion without asking
         \$cG-colors\$cZ             \$cR*\$cZ - colorized output (default)
         \$cG-nocolors\$cZ           \$cR*\$cZ - turn off colors
         \$cG-g\$cZ                  \$cR*\$cZ - adjust audio gain
         \$cG-ng\$cZ                 \$cR*\$cZ - do not adjust audio gain (default)
         \$cG-s\$cZ                    - save configuration to \$cP\"\${CONFIG}\"\$cZ
         \$cG-h\$cZ                    - print this message
         \$cG-v\$cZ                    - print version

\$cR*\$cZ - option affects configuration if \$cP'-s'\$cZ option passed.
\${cP}NOTE: \$cG'-c some_file.jpg -s'\$cP only \${cU}allows\$cZ\$cP cover images, it doesn't set a default one.
\${cZ}Supported \$cU\${cG}FORMATs\${cZ}: flac, m4a, mp3, ogg, wav.
Supported tags for \$cU\${cG}PATTERN\${cZ}: @artist, @album, @year, @track, @title.

It's better to pass \$cP'-p'\$cZ option to see what will happen when actually splitting tracks.
You may want to pass \$cP'-s'\$cZ option for the first run to save default configuration
(output dir, cover image size, etc.) so you won't need to pass a lot of options
every time, just a filename. Script will try to find CUE sheet if it wasn't specified.
It also supports internal CUE sheets (FLAC, APE and WV).\n"

msg="printf"

emsg () {
	$msg "${cR}$1${cZ}"
}

update_encargs () {
	e="\${ENCARGS_${FORMAT}}"
	ENCARGS=`eval echo "$e"`
	ENCHELP=0
}

update_colors () {
	if [ "${NOCOLORS}" -eq 0 ]; then
		cR="\033[31m"
		cG="\033[32m"
		cC="\033[35m"
		cP="\033[36m"
		cU="\033[4m"
		cZ="\033[0m"
	else
		unset cR cG cC cP cU cZ
	fi
}

update_encargs
update_colors

# parse arguments
while [ "$1" ]; do
	case "$1" in
		-o)			 DIR=$2; shift;;
		-of)		 OUTPATTERN=$2; shift;;
		-cue)		 CUE=$2; shift;;
		-cuecharset) CHARSET=$2; shift;;
		-nask)		 NASK=1;;
		-f)			 FORMAT=$2; update_encargs; shift;;
		-e)			 ENCARGS=$2; shift;;
		-eh)		 ENCHELP=1;;
		-c)			 NOPIC=0; PIC=$2; shift;;
		-nc)		 NOPIC=1;;
		-cs)		 PIC_SIZE=$2; shift;;
		-d)			 NOSUBDIRS=0;;
		-nd)		 NOSUBDIRS=1;;
		-p)			 DRY=1;;
		-D)			 REMOVE=1;;
		-nD)		 REMOVE=0;;
		-F)			 FORCE=1;;
		-colors)	 NOCOLORS=0; update_colors;;
		-nocolors)	 NOCOLORS=1; update_colors;;
		-g)			 REPLAY_GAIN=1;;
		-ng)		 REPLAY_GAIN=0;;
		-s)			 SAVE=1;;
		-h|--help|-help) eval "$msg \"${HELP}\""; exit 0;;
		-v|--version)	 $msg "split2${FORMAT} version: ${VERSION}\n"; exit 0;;
		-*) eval "$msg \"${HELP}\""; emsg "\nUnknown option $1\n"; exit 1;;
		*)
			if [ "${INPATH}" ]; then
				eval "$msg \"${HELP}\""
				emsg "\nUnknown option $1\n"
				exit 1
			elif [ ! -r "$1" ]; then
				emsg "Unable to read $1\n"
				exit 2
			else
				INPATH="$1"
			fi;;
	esac
	shift
done

eval "export ENCARGS_${FORMAT}=\"${ENCARGS}\""

# save configuration if needed
if [ ${SAVE} -eq 1 ]; then
	echo "DIR=\"${DIR}\"" > "${CONFIG}"
	echo "OUTPATTERN=\"${OUTPATTERN}\"" >> "${CONFIG}"
	echo "NOSUBDIRS=${NOSUBDIRS}" >> "${CONFIG}"
	echo "NOPIC=${NOPIC}" >> "${CONFIG}"
	echo "REMOVE=${REMOVE}" >> "${CONFIG}"
	echo "PIC_SIZE=${PIC_SIZE}" >> "${CONFIG}"
	echo "NOCOLORS=${NOCOLORS}" >> "${CONFIG}"
	echo "REPLAY_GAIN=${REPLAY_GAIN}" >> "${CONFIG}"
	echo "ENCARGS_flac=\"${ENCARGS_flac}\"" >> "${CONFIG}"
	echo "ENCARGS_m4a=\"${ENCARGS_m4a}\"" >> "${CONFIG}"
	echo "ENCARGS_mp3=\"${ENCARGS_mp3}\"" >> "${CONFIG}"
	echo "ENCARGS_ogg=\"${ENCARGS_ogg}\"" >> "${CONFIG}"
	echo "ENCARGS_wav=\"${ENCARGS_wav}\"" >> "${CONFIG}"
	$msg "${cP}Configuration saved$cZ\n"
fi

METAFLAC="metaflac --no-utf8-convert"
VORBISCOMMENT="vorbiscomment -R -a"
ID3TAG="id3tag -2"
MP4TAGS="mp4tags"
GETTAG="cueprint -n 1 -t"
VALIDATE="sed s/[^-[:space:][:alnum:]&_#,.'\"\(\)!?]//g"

# check & print output format
msg_format="${cG}Output format :$cZ"
case ${FORMAT} in
	flac) $msg "$msg_format FLAC"; enc_help="flac --help";;
	m4a)  $msg "$msg_format M4A"; enc_help="faac --help";;
	mp3)  $msg "$msg_format MP3"; enc_help="lame --help";;
	ogg)  $msg "$msg_format OGG VORBIS"; enc_help="oggenc --help";;
	wav)  $msg "$msg_format WAVE"; enc_help="echo Sorry, no arguments available for this encoder";;
	*)	  emsg "Unknown output format \"${FORMAT}\"\n"; exit 1;;
esac

$msg " (${ENCARGS})\n"

if [ ${ENCHELP} -eq 1 ]; then
	${enc_help}
	exit 0
fi

$msg "${cG}Output dir    :$cZ ${DIR:?Output directory was not set}\n"

# replaces a tag name with the value of the tag. $1=pattern $2=tag_name $3=tag_value
update_pattern () {
	echo "$1" | { [ "$3" ] \
		&& sed "s/[{]@$2\([^}]*\)[}]/$3\1/g;s/@$2/$3/g" \
		|| sed "s/[{]@$2\([^}]*\)[}]//g;s/@$2//g"; }
}

# splits a file
split_file () {
	FILE="$1"

	if [ ! -r "${FILE}" ]; then
		emsg "Can not read the file\n"
		return 1
	fi

	# search for a cue sheet if not specified
	if [ -z "${CUE}" ]; then
		CUE="${FILE}.cue"
		if [ ! -r "${CUE}" ]; then
			CUE="${FILE%.*}.cue"
			if [ ! -r "${CUE}" ]; then
				# try to extract internal one
				CUESHEET=$(${METAFLAC} --show-tag=CUESHEET "${FILE}" 2>/dev/null | sed 's/^cuesheet=//;s/^CUESHEET=//')

				# try WV internal cue sheet
				[ -z "${CUESHEET}" ] && CUESHEET=$(wvunpack -q -c "${FILE}" 2>/dev/null)

				# try APE internal cue sheet (omfg!)
				if [ -z "${CUESHEET}" ]; then
					APETAGEX=$(tail -c 32 "$1" | cut -b 1-8 2>/dev/null)
					if [ "${APETAGEX}" = "APETAGEX" ]; then
						LENGTH=$(tail -c 32 "$1" | cut -b 13-16 | od -t u4 | awk '{printf $2}') 2>/dev/null
						tail -c ${LENGTH} "$1" | grep -a CUESHEET >/dev/null 2>&1
						if [ $? -eq 0 ]; then
							CUESHEET=$(tail -c ${LENGTH} "$1" | sed 's/.*CUESHEET.//g' 2>/dev/null)
							[ $? -ne 0 ] && CUESHEET=""
						fi
					fi
				fi

				if [ "${CUESHEET}" ]; then
					$msg "${cP}Found internal cue sheet$cZ\n"
					CUE="${TMPCUE}"
					echo "${CUESHEET}" > "${CUE}"

					if [ $? -ne 0 ]; then
						emsg "Unable to save internal cue sheet\n"
						return 1
					fi
				else
					unset CUE
				fi
			fi
		fi
	fi

	# print cue sheet filename
	if [ -z "${CUE}" ]; then
		emsg "No cue sheet\n"
		return 1
	fi

	# cue sheet charset
	[ -z "${CHARSET}" ] && CHARSET="utf-8" || $msg "${cG}Cue charset : $cP${CHARSET} -> utf-8$cZ\n"

	CUESHEET=$(iconv -f "${CHARSET}" -t utf-8 "${CUE}" 2>/dev/null)

	if [ $? -ne 0 ]; then
		[ "${CHARSET}" = "utf-8" ] \
			&& emsg "Cue sheet is not utf-8\n" \
			|| emsg "Unable to convert cue sheet from ${CHARSET} to utf-8\n"

		if [ ${NASK} -eq 0 ]; then
			while [ 1 ]; do
				echo -n "Please enter the charset (or just press ENTER to ignore) > "
				read CHARSET

				[ -z "${CHARSET}" ] && break
				$msg "${cG}Converted cue sheet:$cZ\n"
				iconv -f "${CHARSET}" -t utf-8 "${CUE}" || continue

				echo -n "Is this right? [Y/n] > "
				read YEP
				[ -z "${YEP}" -o "${YEP}" = "y" -o "${YEP}" = "Y" ] && break
			done

			CUESHEET=$(iconv -f "${CHARSET}" -t utf-8 "${CUE}" 2>/dev/null)
		fi
	fi

	if [ "${CHARSET}" -a "${CHARSET}" != "utf-8" ]; then
		CUE="${TMPCUE}"
		echo "${CUESHEET}" > "${CUE}"

		if [ $? -ne 0 ]; then
			emsg "Unable to save converted cue sheet\n"
			return 1
		fi
	fi

	# search for a front cover image
	if [ ${NOPIC} -eq 1 ]; then
		unset PIC
	elif [ -z "${PIC}" ]; then
		# try common names 
		SDIR=$(dirname "${FILE}")

		for i in cover.jpg front_cover.jpg folder.jpg; do
			if [ -r "${SDIR}/$i" ]; then
				PIC="${SDIR}/$i"
				break
			fi
		done

		# try to extract internal one
		if [ -z "${PIC}" ]; then
			${METAFLAC} --export-picture-to="${TMPPIC}" "${FILE}" 2>/dev/null
			if [ $? -ne 0 ]; then
				unset PIC
			else
				PIC="${TMPPIC}"
			fi
		fi
	fi

	$msg "${cG}Cue sheet     :$cZ ${CUE}\n"
	$msg "${cG}Cover image   :$cZ ${PIC:-not set}\n"

	# file removal warning
	if [ ${REMOVE} -eq 1 ]; then
		msg_removal="\n${cR}Also remove original"
		[ ${FORCE} -eq 1 ] \
			&& $msg "$msg_removal (WITHOUT ASKING)$cZ\n" \
			|| $msg "$msg_removal if user says 'y'$cZ\n"
	fi

	# get common tags
	TAG_ARTIST=$(${GETTAG} %P "${CUE}" 2>/dev/null)
	TAG_ALBUM=$(${GETTAG} %T "${CUE}" 2>/dev/null)
	TRACKS_NUM=$(${GETTAG} %N "${CUE}" 2>/dev/null)

	if [ -z "${TRACKS_NUM}" ]; then
		emsg "Failed to get number of tracks from CUE sheet.\n"
		emsg "There may be an error in the sheet.\n"
		emsg "Running ${GETTAG} %N \"${CUE}\" produces this:\n"
		${GETTAG} %N "${CUE}"
		return 1
	fi

	TAG_GENRE=$(awk '{ if (/REM[ \t]+GENRE[ \t]+(.*)/) { print $0; exit } }' < "${CUE}")
	TAG_GENRE=$(echo ${TAG_GENRE} | sed 's/REM[ \t]\+GENRE[ \t]\+//;s/"\(.*\)"/\1/')

	YEAR=$(awk '{ if (/REM[ \t]+DATE/) { printf "%i", $3; exit } }' < "${CUE}")
	YEAR=$(echo ${YEAR} | tr -d -c '[:digit:]')

	unset TAG_DATE

	if [ "${YEAR}" ]; then
		[ ${YEAR} -ne 0 ] && TAG_DATE="${YEAR}"
	fi

	$msg "\n${cG}Artist :$cZ ${TAG_ARTIST}\n"
	$msg "${cG}Album  :$cZ ${TAG_ALBUM}\n"
	[ "${TAG_GENRE}" ] && $msg "${cG}Genre  :$cZ ${TAG_GENRE}\n"
	[ "${TAG_DATE}"  ] && $msg "${cG}Year   :$cZ ${TAG_DATE}\n"
	$msg "${cG}Tracks :$cZ ${TRACKS_NUM}\n\n"

	# those tags won't change, so update the pattern now
	DIR_ARTIST=$(echo ${TAG_ARTIST} | ${VALIDATE})
	DIR_ALBUM=$(echo ${TAG_ALBUM} | ${VALIDATE})
	PATTERN=$(update_pattern "${OUTPATTERN}" "artist" "${DIR_ARTIST}")
	PATTERN=$(update_pattern "${PATTERN}" "album" "${DIR_ALBUM}")
	PATTERN=$(update_pattern "${PATTERN}" "year" "${TAG_DATE}")
	PATTERN=$(update_pattern "${PATTERN}" "ext" "${FORMAT}")

	# construct output directory name
	OUT="${DIR}"

	if [ ${NOSUBDIRS} -eq 0 ]; then
		# add path from the pattern
		path=$(dirname "${PATTERN}")
		[ "${path}" != "${PATTERN}" ] && OUT="${OUT}/${path}"
	fi

	# remove path from the pattern
	PATTERN=$(basename "${PATTERN}")

	$msg "${cP}Saving tracks to $cZ\"${OUT}\"\n"

	# split to tracks
	if [ ${DRY} -ne 1 ]; then
		# remove if empty and create output dir
		if [ ${NOSUBDIRS} -eq 0 ]; then
			rmdir "${OUT}" 2>/dev/null
			mkdir -p "${OUT}"
			[ $? -ne 0 ] && { emsg "Failed to create output directory ${OUT} (already split?)\n"; return 1; }
		fi

		case ${FORMAT} in
			flac) ENC="flac flac ${ENCARGS} - -o %f"; RG="metaflac --add-replay-gain";;
			m4a)  ENC="cust ext=m4a faac ${ENCARGS} -o %f -"; RG="aacgain";;
			mp3)  ENC="cust ext=mp3 lame ${ENCARGS} - %f"; RG="mp3gain";;
			ogg)  ENC="cust ext=ogg oggenc ${ENCARGS} - -o %f"; RG="vorbisgain -a";;
			wav)  ENC="wav ${ENCARGS}"; REPLAY_GAIN=0;;
			*)	  emsg "Unknown output format ${FORMAT}\n"; exit 1;;
		esac

		# split to tracks
		cuebreakpoints "${CUE}" 2>/dev/null | \
			shnsplit -O never -o "${ENC}" -d "${OUT}" -t "%n" "${FILE}"
		if [ $? -ne 0 ]; then
			emsg "Failed to split\n"
			return 1
		fi

		# prepare cover image
		if [ "${PIC}" ]; then
			convert "${PIC}" -resize "${PIC_SIZE}" "${TMPPIC}"
			if [ $? -eq 0 ]; then
				PIC="${TMPPIC}"
			else
				$msg "${cR}Failed to convert cover image$cZ\n"
				unset PIC
			fi
		fi
	fi

	# set tags and rename
	$msg "\n${cP}Setting tags$cZ\n"

	i=1
	while [ $i -le ${TRACKS_NUM} ]; do
		TAG_TITLE=$(cueprint -n $i -t %t "${CUE}" 2>/dev/null)
		FILE_TRACK="$(printf %02i $i)"
		FILE_TITLE=$(echo ${TAG_TITLE} | ${VALIDATE})
		f="${OUT}/${FILE_TRACK}.${FORMAT}"

		TAG_PERFORMER=$(cueprint -n $i -t %p "${CUE}" 2>/dev/null)

		if [ "${TAG_PERFORMER}" -a "${TAG_PERFORMER}" != "${TAG_ARTIST}" ]; then
			$msg "$i: $cG${TAG_PERFORMER} - ${TAG_TITLE}$cZ\n"
		else
			TAG_PERFORMER="${TAG_ARTIST}"
			$msg "$i: $cG${TAG_TITLE}$cZ\n"
		fi

		FINAL=$(update_pattern "${OUT}/${PATTERN}" "title" "${FILE_TITLE}")
		FINAL=$(update_pattern "${FINAL}" "track" "${FILE_TRACK}")

		if [ ${DRY} -ne 1 ]; then
			mv "$f" "${FINAL}"
			if [ $? -ne 0 ]; then
				emsg "Failed to rename track file\n"
				return 1
			fi
		fi

		if [ ${DRY} -ne 1 ]; then
			case ${FORMAT} in
				flac)
					${METAFLAC} --remove-all-tags \
						--set-tag="ARTIST=${TAG_PERFORMER}" \
						--set-tag="ALBUM=${TAG_ALBUM}" \
						--set-tag="TITLE=${TAG_TITLE}" \
						--set-tag="TRACKNUMBER=$i" \
						"${FINAL}" >/dev/null
					RES=$?

					[ "${TAG_GENRE}" ] && { ${METAFLAC} --set-tag="GENRE=${TAG_GENRE}" "${FINAL}" >/dev/null; RES=$RES$?; }
					[ "${TAG_DATE}" ] && { ${METAFLAC} --set-tag="DATE=${TAG_DATE}" "${FINAL}" >/dev/null; RES=$RES$?; }
					[ "${PIC}" ] && { ${METAFLAC} --import-picture-from="${PIC}" "${FINAL}" >/dev/null; RES=$RES$?; }
					;;

				mp3)
					${ID3TAG} "-a${TAG_PERFORMER}" \
						"-A${TAG_ALBUM}" \
						"-s${TAG_TITLE}" \
						"-t$i" \
						"-T${TRACKS_NUM}" \
						"${FINAL}" >/dev/null
					RES=$?

					[ "${TAG_GENRE}" ] && { ${ID3TAG} -g"${TAG_GENRE}" "${FINAL}" >/dev/null; RES=$RES$?; }
					[ "${TAG_DATE}" ] && { ${ID3TAG} -y"${TAG_DATE}" "${FINAL}" >/dev/null; RES=$RES$?; }
					;;

				ogg)
					${VORBISCOMMENT} "${FINAL}" \
						-t "ARTIST=${TAG_PERFORMER}" \
						-t "ALBUM=${TAG_ALBUM}" \
						-t "TITLE=${TAG_TITLE}" \
						-t "TRACKNUMBER=$i" >/dev/null
					RES=$?

					[ "${TAG_GENRE}" ] && { ${VORBISCOMMENT} "${FINAL}" -t "GENRE=${TAG_GENRE}" >/dev/null; RES=$RES$?; }
					[ "${TAG_DATE}" ] && { ${VORBISCOMMENT} "${FINAL}" -t "DATE=${TAG_DATE}" >/dev/null; RES=$RES$?; }
					;;

				m4a)
					${MP4TAGS} "${FINAL}" \
						-a "${TAG_PERFORMER}" \
						-A "${TAG_ALBUM}" \
						-s "${TAG_TITLE}" \
						-t "$i" \
						-T "${TRACKS_NUM}" >/dev/null
					RES=$?

					[ "${TAG_GENRE}" ] && { ${MP4TAGS} "${FINAL}" -g "${TAG_GENRE}" >/dev/null; RES=$RES$?; }
					[ "${TAG_DATE}" ] && { ${MP4TAGS} "${FINAL}" -y "${TAG_DATE}" >/dev/null; RES=$RES$?; }
					[ "${PIC}" ] && { ${MP4TAGS} "${FINAL}" -P "${PIC}" >/dev/null; RES=$RES$?; }
					;;

				wav)
					RES=0
					;;

				*)
					emsg "Unknown output format ${FORMAT}\n"
					return 1
					;;
			esac

			if [ ${RES} -ne 0 ]; then
				emsg "Failed to set tags for track\n"
				return 1
			fi
		fi

		$msg "   -> ${cP}${FINAL}$cZ\n"

		i=$(($i + 1))
	done

	# adjust gain
	if [ ${REPLAY_GAIN} -ne 0 ]; then
		$msg "\n${cP}Adjusting gain$cZ\n"

		if [ ${DRY} -ne 1 ]; then
			${RG} "${OUT}/"*.${FORMAT} >/dev/null

			if [ $? -ne 0 ]; then
				emsg "Failed to adjust gain for track\n"
				return 1
			fi
		fi
	fi

	rm -f "${TMPPIC}"
	rm -f "${TMPCUE}"

	if [ ${DRY} -ne 1 -a ${REMOVE} -eq 1 ]; then
		YEP="n"

		if [ ${FORCE} -ne 1 ]; then
			echo -n "Are you sure you want to delete original? [y/N] > "
			read YEP
		fi

		[ "${YEP}" = "y" -o "${YEP}" = "Y" -o ${FORCE} -eq 1 ] && rm -f "${FILE}"
	fi

	return 0
}

# searches for files in a directory and splits them
split_collection () {
	rm -f "${FAILED}"
	NUM_FAILED=0
	OLDIFS=${IFS}
	OLDCHARSET="${CHARSET}"
	# set IFS to newline. we do not use 'read' here because we may want to ask user for input
	IFS="
"

	for FILE in `find "$1" -iname '*.flac' -o -iname '*.ape' -o -iname '*.wv'`; do
		IFS=${OLDIFS}
		CHARSET=${OLDCHARSET}
		$msg "$cG>> $cC\"${FILE}\"$cZ\n"
		unset PIC CUE
		split_file "${FILE}"

		if [ ! $? -eq 0 ]; then
			emsg "Failed to split \"${FILE}\"\n"
			echo "${FILE}" >> "${FAILED}"
			NUM_FAILED=$((${NUM_FAILED} + 1))
		fi

		echo
	done

	if [ ${NUM_FAILED} -ne 0 ]; then
		emsg "${NUM_FAILED} file(s) failed to split (already split?):\n"
		$msg "${cR}\n"
		sort "${FAILED}" -o "${FAILED}"
		cat "${FAILED}"
		emsg "\nThese files are also listed in ${FAILED}.\n"
		return 1
	fi

	return 0
}

if [ -d "${INPATH}" ]; then
	if [ ! -x "${INPATH}" ]; then
		emsg "Directory \"${INPATH}\" is not accessible\n"
		exit 2
	fi
	$msg "${cG}Input dir     :$cZ ${INPATH}$cZ\n\n"
	split_collection "${INPATH}"
elif [ "${INPATH}" ]; then
	split_file "${INPATH}"
else
	emsg "No input filename given. Use -h for help.\n"
	exit 1
fi

# exit code of split_collection or split_file
STATUS=$?

$msg "\n${cP}Finished$cZ\n"

[ ${STATUS} -ne 0 ] && exit 3
