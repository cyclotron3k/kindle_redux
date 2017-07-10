require 'digest/md5'
require 'evernote-thrift'

class KindleRedux::Modules::Shopping
	include KindleRedux::Modules::Module

	def render
		canvas.text "Shopping List", x: 10, y: 40, font_size: 30, font_family: 'garamond'
		get_data.each_with_index do |line, i|
			canvas.text line, x: 10, y: 62 + (18 * i), font_size: 12, font_family: 'arial'
		end
		canvas.render
	end

	private

	def get_data
		auth_token = ENV['EVERNOTE_AUTH_TOKEN']
		user_store_url = "https://www.evernote.com/edam/user"
		user_store_transport = Thrift::HTTPClientTransport.new(user_store_url)
		user_store_protocol = Thrift::BinaryProtocol.new(user_store_transport)
		user_store = Evernote::EDAM::UserStore::UserStore::Client.new(user_store_protocol)

		version_ok = user_store.checkVersion(
			"Evernote EDAMTest (Ruby)",
			Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
			Evernote::EDAM::UserStore::EDAM_VERSION_MINOR
		)

		raise "Bad version" unless version_ok

		note_store_url = user_store.getNoteStoreUrl(auth_token)

		note_store_transport = Thrift::HTTPClientTransport.new(note_store_url)
		note_store_protocol = Thrift::BinaryProtocol.new(note_store_transport)
		note_store = Evernote::EDAM::NoteStore::NoteStore::Client.new(note_store_protocol)
		notebooks = note_store.listNotebooks(auth_token)
		default_notebook = notebooks.first

		nf = Evernote::EDAM::NoteStore::NoteFilter.new
		nf.notebookGuid = default_notebook.guid
		nf.words = 'Shopping'
		found = note_store.findNotes auth_token, nf, 0, 1
		note = note_store.getNote auth_token, found.notes.first.guid, true, false, false, false

		recursive_textify Nokogiri::XML(note.content).at_css('en-note')
	end

	def recursive_textify(node)
		node.children.flat_map do |child|
			if child.text?
				child.text
			elsif child.name == "br"
				""
			else
				recursive_textify child
			end
		end
	end
end
