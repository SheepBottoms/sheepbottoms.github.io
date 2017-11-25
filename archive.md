---
bg: "tag.jpg"
layout: page
permalink: /archive/
title: "Archive"
crawlertitle: "All articles"
summary: "Paige and Jimmy's travel blog"
active: archive
---



{% assign grouping = site.posts | sort_by:"date" | group_by:"group" %}
{% for group in grouping %}
  <h4>{{ group.name }}</h4>
  <ul class="year">
  {% for post in group.items %}
      <li>
        {% if post.lastmod %}
          <a href="{{ post.url }}">{{ post.title }}</a>
          <span class="date">{{ post.lastmod | date: "%d-%m-%Y"  }}</span>
        {% else %}
          <a href="{{ post.url }}">{{ post.title }}</a>
          <span class="date">{{ post.date | date: "%d-%m-%Y"  }}</span>
        {% endif %}
      </li>
  {% endfor %}
  </ul>
{% endfor %}


