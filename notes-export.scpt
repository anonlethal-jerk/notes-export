--
-- notes-export.scpt
-- Alex Chan <alex@alexwlchan.net>
-- edits by:
-- A NonLethal Jerk <anonlethaljerk@gmail.com>
--
-- Export all the notes from Notes.app into a folder as HTML text.
-- A very basic backup script.
--
-- Usage:
--  * Open this file in Script Editor
--  * Run
--  * Select a folder to export files to
--
-- Output:
--  * A collection of UTF-16 BE encoded (AppleScript's default?) HTML files
--  * A list of attachment names for each note.
--
-- Known issues:
--  * Only the names of attachments are exported, not the files themselves. (Look for the files in ~Library/Group Containers/group.com.apple.notes/Media).
--  * Some attachment types (e.g. app links) show up as "Missing value"
--  * Some formatting is lost.
--  * A note with the same title and date/time as a previously exported note will be overwritten. (not likely)
--  * It will export notes in the "Recently Deleted" folder which haven't been purged from disk yet.
--

set exportFolder to (choose folder) as string


-- Find and Replace text.  Yes, this really takes 11 lines.
-- Taken from http://brucep.net/2007/replace-text/
on replaceText(find, replace, subject)
	set prevTIDs to text item delimiters of AppleScript
	set text item delimiters of AppleScript to find
	set subject to text items of subject

	set text item delimiters of AppleScript to replace
	set subject to "" & subject
	set text item delimiters of AppleScript to prevTIDs

	return subject
end replaceText


-- Get an HTML file to save the note in.  We have to escape the colons or AppleScript gets upset.
on noteNameToFilePath(noteName)
	global exportFolder
	return (exportFolder & replaceText(":", "_", noteName) & ".html")
end noteNameToFilePath


tell application "Notes"
	set attachmentLog to open for access (exportFolder & "_attachments.txt") with write permission
	repeat with theNote in notes

		-- Get basic Date and Time (seconds since start of day) for filename
		set {year:y, month:m, day:d, time:t} to (creation date of theNote as date)
		set cDate to y & "_" & m & "_" & d & "-" & t

		-- Write the body of the note out to file as HTML
		set filepath to noteNameToFilePath(cDate & "-" & name of theNote as string) of me
		set noteFile to open for access filepath with write permission
		write (body of theNote as string) to noteFile as Unicode text
		close access noteFile

		-- Record a list of attachments for this file
		if (count of (attachments of theNote)) is greater than 0 then
			write ("\n" & name of theNote & ":\n\n") to attachmentLog
		end if

		repeat with theAttachment in attachments of theNote
			write ("* " & name of theAttachment & "\n") to attachmentLog
		end repeat

	end repeat

	close access attachmentLog
end tell
