INSERT INTO names (id, name, uid) VALUES (1, fb_get_info("name"), SELECT id FROM uids WHERE uids.uid = fb_get_info("id"))
