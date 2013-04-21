CREATE TABLE pages
(
  url text NOT NULL,
  id serial NOT NULL,
  CONSTRAINT pages_pkey PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);

CREATE TABLE updates
(
  id serial NOT NULL,
  page_id integer NOT NULL,
  created_at timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT updates_pkey PRIMARY KEY (id ),
  CONSTRAINT updates_page_id_fkey FOREIGN KEY (page_id)
      REFERENCES pages (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);