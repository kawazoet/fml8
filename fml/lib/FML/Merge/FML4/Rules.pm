
# -*- perl -*-
#     *** CAUTION *** 
#     DO NOT EDIT THIS FILE BY HAND!.
#     THIS FILE IS AUTOMATICALLY GENERATED BY gen_rules.pl.
#
# $FML$
#

package FML::Merge::FML4::Rules;


# Descriptions: translate fml4 rule to the corresponding fml8 one.
#    Arguments: OBJ($self)
#               HASH_REF($dispatch) HASH_REF($diff) STR($key) STR($value)
# Side Effects: none
# Return Value: STR
sub translate
{
    my ($self, $dispatch, $diff, $key, $value) = @_;
    my $fp_rule_convert           = $dispatch->{ rule_convert };
    my $fp_rule_prefer_fml4_value = $dispatch->{ rule_prefer_fml4_value };
    my $fp_rule_prefer_fml8_value = $dispatch->{ rule_prefer_fml8_value };
    my $s;


   if ($key eq 'USE_DISTRIBUTE_FILTER' && $value == 1) {
      $s = undef;
      $s .= "use_article_filter = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_DISTRIBUTE_FILTER' && $value == 0) {
      $s = undef;
      $s .= "use_article_filter = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_NULL_BODY' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_null_mail_body";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_NULL_BODY' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_null_mail_body";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_COMMAND' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_old_fml_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_COMMAND' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_old_fml_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_2BYTES_COMMAND' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_japanese_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_2BYTES_COMMAND' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_japanese_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_INVALID_COMMAND' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_invalid_fml_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_INVALID_COMMAND' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_invalid_fml_command_syntax";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_ONE_LINE_BODY' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_one_line_message";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_ONE_LINE_BODY' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_one_line_message";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_MS_GUID' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_ms_guid";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_MS_GUID' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_ms_guid";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_INVALID_JAPANESE' && $value == 0) {
      $s = undef;
      $s .= "article_text_plain_filter_rules -= reject_not_iso2022jp_japanese_string";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'FILTER_ATTR_REJECT_INVALID_JAPANESE' && $value == 1) {
      $s = undef;
      $s .= "article_text_plain_filter_rules += reject_not_iso2022jp_japanese_string";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'CONTENT_HANDLER_CUTOFF_EMPTY_MESSAGE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'CONTENT_HANDLER_REJECT_EMPTY_MESSAGE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'HTML_MAIL_DEFAULT_HANDLER' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'CONTROL_ADDRESS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_LOG_MAIL' && $value == 0) {
      $s = undef;
      $s .= "use_incoming_mail_cache = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_LOG_MAIL' && $value == 1) {
      $s = undef;
      $s .= "use_incoming_mail_cache = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'LOG_MAIL_DIR' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOG_MAIL_SEQ' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'PERMIT_COMMAND_FROM' && $value eq 'anyone') {
      $s = undef;
      $s .= "command_mail_restrictions = reject_system_special_accounts permit_anyone";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'XMLNAME' && $value eq 'X-ML-Name:') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'XMLCOUNT' && $value eq 'X-Mail-Count') {
      $s = undef;
      $s .= "article_header_rewrite_rules += add_fml_traditional_article_id";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'SUBJECT_TAG_TYPE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'BRACKET' && $value eq 'Elena') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'BRACKET_SEPARATOR' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'SUBJECT_FREE_FORM' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'SUBJECT_FREE_FORM_REGEXP' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'SUBJECT_FORM_LONG_ID' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_ERRORS_TO' && $value == 1) {
      $s = undef;
      $s .= "article_header_rewrite_rules += rewrite_errors_to";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_ERRORS_TO' && $value == 0) {
      $s = undef;
      $s .= "article_header_rewrite_rules -= rewrite_errors_to";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_RFC2369' && $value == 1) {
      $s = undef;
      $s .= "article_header_rewrite_rules += add_rfc2369";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_RFC2369' && $value == 0) {
      $s = undef;
      $s .= "article_header_rewrite_rules -= add_rfc2369";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'TZone' && $value eq '+0900') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'TZONE_DST' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SKIP_FIELDS' && $value eq 'Return-Receipt-To') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'LANGUAGE' && $value eq 'Japanese') {
      $s = undef;
      $s .= "language_preference_order = ja en";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'MAXLEN_COMMAND_INPUT' && $value == 128) {
      $s = undef;
      $s .= "command_mail_line_length_limit = MAXLEN_COMMAND_INPUT";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'MAXNUM_COMMAND_INPUT' && defined $value) {
      $s = undef;
      $s .= "command_mail_valid_command_limit = MAXNUM_COMMAND_INPUT";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'CHADDR_KEYWORD' && $value eq 'chaddr|change\-address|change') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'MAINTAINER' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'MSEND_RC' && $value eq '$VARLOG_DIR/msendrc') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'LOG_MESSAGE_ID' && $value eq '$VARRUN_DIR/msgidcache') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'MESSAGE_ID_CACHE_BUFSIZE' && $value == 6000) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'LOG_MAILBODY_CKSUM' && $value eq '$VARRUN_DIR/bodycksumcache') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'MEMBER_LIST' && $value ne '$DIR/members') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'ACTIVE_LIST' && $value ne '$DIR/actives') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'GUIDE_FILE' && $value ne '$DIR/guide') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'OBJECTIVE_FILE' && $value ne '$DIR/objective') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SPOOL_DIR' && $value eq 'spool') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'LOGFILE' && $value ne '$DIR/log') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOGFILE_SUFFIX' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SUMMARY_FILE' && $value ne '$DIR/summary') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SEQUENCE_FILE' && $value ne '$DIR/seq') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'TMP_DIR' && $value eq 'tmp') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'HOST' && $value ne 'localhost') {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'PORT' && $value != 25) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'SMTP_SENDER' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SMTP_LOG' && $value eq '$VARLOG_DIR/_smtplog') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_SMTP_LOG_ROTATE' && $value == 1) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SMTP_LOG_ROTATE_EXPIRE_LIMIT' && $value == 90) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'NUM_SMTP_LOG_ROTATE' && $value == 8) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'SMTP_LOG_ROTATE_TYPE' && $value eq 'number') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'VAR_DIR' && $value eq 'var') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'MCI_SMTP_HOSTS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'OUTGOING_ADDRESS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'POSTFIX_VERP_DELIMITERS' && $value eq '+=') {
      $s = undef;
      $s .= "postfix_verp_delimiters = POSTFIX_VERP_DELIMITERS";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'VARLOG_DIR' && $value eq 'var/log') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'VARRUN_DIR' && $value eq 'var/run') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'NOT_USE_SPOOL' && $value == 1) {
      $s = undef;
      $s .= "use_spool = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'NOT_USE_SPOOL' && $value == 0) {
      $s = undef;
      $s .= "use_spool = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'VARDB_DIR' && $value eq 'var/db') {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'LANGUAGE' && $value eq 'English') {
      $s = undef;
      $s .= "language_preference_order = en ja";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'AUTO_HTML_GEN' && $value == 1) {
      $s = undef;
      $s .= "use_html_archive = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'AUTO_HTML_GEN' && $value == 0) {
      $s = undef;
      $s .= "use_html_archive = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_NEW_HTML_GEN' && $value == 1) {
      $s = undef;
      $s .= "use_html_archive = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'USE_NEW_HTML_GEN' && $value == 0) {
      $s = undef;
      $s .= "use_html_archive = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'CPU_TYPE_MANUFACTURER_OS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'STRUCT_SOCKADDR' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOCK_SH' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOCK_EX' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOCK_NB' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LOCK_UN' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'COMPAT_SOLARIS2' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'NOT_USE_TIOCNOTTY' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'HAS_GETPWUID' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'HAS_GETPWGID' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'HAS_ALARM' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'UNISTD' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'SENDMAIL' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'TAR' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'UUENCODE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'COMPRESS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'ZCAT' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'LHA' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'ISH' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'ZIP' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'BZIP2' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGP' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGP5' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGPE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGPK' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGPS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PGPV' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'GPG' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'RCS' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'CI' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'BASE64_DECODE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'BASE64_ENCODE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'MD5' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'AUTO_REGISTRATION_DEFAULT_MODE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'MESSAGE_LANGUAGE' && $value eq 'Japanese') {
      $s = undef;
      $s .= "language_preference_order = ja en";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'CONFIRMATION_LIST' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'MESSAGE_LANGUAGE' && $value eq 'English') {
      $s = undef;
      $s .= "language_preference_order = en ja";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'FILE_TO_REGIST' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'DOMAINNAME' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'REMOTE_ADMINISTRATION' && $value == 0) {
      $s = undef;
      $s .= "use_admin_command_mail_fucntion = no";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'REMOTE_ADMINISTRATION' && $value == 1) {
      $s = undef;
      $s .= "use_admin_command_mail_fucntion = yes";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'REMOTE_ADMINISTRATION_AUTH_TYPE' && $value eq 'crypt') {
      $s = undef;
      $s .= "admin_command_mail_restrictions += check_admin_member_password";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'FQDN' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'ADMIN_MEMBER_LIST' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'PASSWD_FILE' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'ADMIN_LOG_DEFAULT_LINE_LIMIT' && defined $value) {
      $s = undef;
      $s .= "log_command_tail_starting_location = ADMIN_LOG_DEFAULT_LINE_LIMIT";
      $s .= "\n";
      return $s if defined $s;
   }
   
   if ($key eq 'MAIL_LIST' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   if ($key eq 'REJECT_ADDR' && defined $value) {
      $s = undef;
      $s .= &$fp_rule_convert($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
   if ($key eq 'PERMIT_POST_FROM' && $value eq 'anyone') {
      $s = undef;
      $s .= "article_post_restrictions = reject_system_special_accounts permit_anyone";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'CHECK_MESSAGE_ID' && $value == 0) {
      $s = undef;
      $s .= "incoming_mail_header_loop_check_rules -= check_message_id";
      $s .= "\n";
      return $s if defined $s;
   }
   
   
   if ($key eq 'INCOMING_MAIL_SIZE_LIMIT' && $value != 0) {
      $s = undef;
      $s .= &$fp_rule_prefer_fml8_value($self, $diff, $key, $value);
      return $s if defined $s;
   }
   
   
      if ($key eq 'PERMIT_POST_FROM' && $value eq 'members_only') {
         $s = undef;
         
         if ($key eq 'REJECT_POST_HANDLER' && $value eq 'reject') {
            $s = undef;
            $s .= "article_post_restrictions = reject_system_special_accounts permit_member_maps reject";
         $s .= "\n";
         }
      return $s if defined $s;
   }
   
   
   return '';
} # sub translate

1;
