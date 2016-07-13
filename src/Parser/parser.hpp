#pragma once

#include "../Error/errorhandler.hpp"
#include "../options.hpp"
#include "../token.hpp"
#include "../utilmacro.hpp"

#include <iosfwd>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

struct Functor_Pre_Info_t {
	std::vector<std::string> name;
	size_t trait_argument_count = 0;
	std::pair<size_t, size_t> argument_count    = std::make_pair(size_t{0}, size_t{0});
	enum : bool { INFIX, POSTFIX } calling_type = POSTFIX;
	intmax_t presidence = 0;
	bool declared       = false;
	bool abouted        = false;
	std::unordered_map<std::string, std::vector<std::string>> about_pairs;
};

namespace nip {
	namespace parse {
		class Parser {
		  public:
			Parser(nip::error::Error_Handler& e, nip::Options& o, std::ostream& err)
			    : errhdlr(e), opt(o), err_stream(err), cur_symbol(NUL){};
			void parse(const std::vector<nip::Token_t>&, const Token_Cache_t&);

		  private:
			nip::error::Error_Handler& errhdlr;
			nip::Options& opt;
			std::ostream& err_stream;
			nip::Token_t cur_symbol;
			size_t last_token_data = 0;

			std::vector<nip::Token_t>::const_iterator start, current, end;
			Token_Cache_t token_caches;

			// METADATA PRE-PARSE
			std::vector<std::string> current_qualified_name;
			void metadata_preprocessor();
			void metadata_scan(bool scan_for_abouts, size_t start_indent);

			std::vector<Functor_Pre_Info_t> functor_pre_info;

			enum blocktype_t : bool { INDENTATION, BRACKETS };
			std::vector<blocktype_t> block_type;

			ALWAYS_INLINE void next_sym();
			ALWAYS_INLINE void error(const char* msg,
			                         nip::error::_Error_Type et = nip::error::FATAL_ERROR);
			template <class... Args>
			ALWAYS_INLINE bool is(nip::TokenType_t, nip::TokenType_t, Args...);
			ALWAYS_INLINE bool is(nip::TokenType_t);
			template <class... Args>
			ALWAYS_INLINE bool accept(nip::TokenType_t, nip::TokenType_t, Args...);
			ALWAYS_INLINE bool accept(nip::TokenType_t);
			ALWAYS_INLINE bool expect(nip::TokenType_t tt, const char* msg = "unexpected token",
			                          nip::error::_Error_Type et = nip::error::FATAL_ERROR);

			void program();

			// Elements
			void element();
			void import_element();
			void export_element();
			void term();

			// Declarations
			void trait_declaration();
			void intrinsic_declaration();

			// Definitions
			void function_definition();
			void instance_definition();
			void permission_definition();
			void type_definition();
			void vocabulary_definition();

			// Metadata
			void about_section();
			void metadata_field();

			// Synonym
			void word_synonym();
			void type_synonym();
			void vocabulary_synonym();

			// Imports
			void import_name();

			// Terms
			void literal_term();
			void word_term();
			void section_term();
			void group_term();
			void vector_term();
			void lambda_term();
			void match_term();
			void if_term();
			void do_term();
			void block_term();
			void with_term();

			// General stuff
			ALWAYS_INLINE void generic_block();
			void block_start();
			void block_end();
			void qualified_name();
			void trait_arguments();
			void type_name();
			void signature();
			void endofstatement();
			void newlines();
		};
	}
}

class Parse_Fatal_Error_t : public std::exception {
  public:
	const char* what() const throw() {
		return "There was a parser error\n";
	}
};

extern Parse_Fatal_Error_t Parse_Fatal_Error;

// This structure holds information on functions so they can be properly called

#include "parserfunc.tpp"
