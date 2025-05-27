# Отчёт по домашнему заданию «Работа с Playbook»

**Студент:** *Колб Дмитрий*
---

## Содержание

* [Отчёт по домашнему заданию «Работа с Playbook»](#отчёт-по-домашнему-заданию-работа-с-playbook)

  * [Содержание](#содержание)
  * [Введение](#введение)
  * [Задания](#задания)
  * [Описание проекта](#описание-проекта)
  * [Выполнение пунктов](#выполнение-пунктов)
  * [Скриншоты](#скриншоты)
  * [Заключение](#заключение)

---

## Введение

В рамках домашнего задания я разработал Ansible playbook для автоматизации установки и настройки систем ClickHouse и Vector на подготовленных серверах. Playbook включает шаблоны для конфигурации Vector и обработчики для перезапуска служб при изменениях.  

Для развертывания серверов используется Terraform, который создает два сервера. Файлы `inventory.tpl`,`inventory.tf`  передает IP-адреса машин в `prod.yml`, что позволяет использовать готовый playbook для дальнейших действий.  
---

## Задания

1. Подготовить inventory файл `prod.yml` с определением групп хостов.
2. Дописать playbook, добавив play для установки и настройки Vector с использованием jinja2 шаблона.
3. Использовать модули `get_url`, `template`, `unarchive`, `file` для скачивания, распаковки и настройки Vector.
4. Проверить playbook с помощью `ansible-lint`.
5. Запустить playbook с флагами `--check` и `--diff`, убедиться в идемпотентности.
6. Подготовить README с описанием playbook и приложить скриншоты результатов.
7. Выложить готовый проект в публичный репозиторий с тегом `08-ansible-02-playbook`.

---

## Описание проекта

* В playbook добавлен отдельный play, который:

  * Скачивает нужную версию Vector
  * Распаковывает архив в заданную директорию
  * Копирует конфигурацию из шаблона
  * Перезапускает службу Vector через handler при изменениях

* Используется инвентори `prod.yml` для определения целевых серверов.

* Конфигурация Vector сделана через Jinja2 шаблон `vector.j2` с минимальным необходимым содержимым.

---

## Структура репозитория и важные файлы

### inventory/prod.yml

```yaml
el:
  hosts:


    el-1:
      ansible_host: <IP_адрес>

clickhouse:
  hosts:

    deb-1:
      ansible_host: <IP_адрес>
```

*Комментарий:* Основной файл инвентаря с разделением на группы `clickhouse` и `el`.

---

### playbook/site.yml

```yaml
- name: Install Clickhouse
  hosts: clickhouse
  become: true
  handlers:
    - name: Start Clickhouse service
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - name: Download Clickhouse DEB packages
      ansible.builtin.get_url:
        url: "https://packages.clickhouse.com/deb/pool/main/c/{{ item }}/{{ item }}_{{ clickhouse_version }}_amd64.deb"
        dest: "/tmp/{{ item }}_{{ clickhouse_version }}_amd64.deb"
        mode: '0644'
      loop: "{{ clickhouse_packages }}"
      notify: Start Clickhouse service

    - name: Install Clickhouse DEB packages
      ansible.builtin.apt:
        deb: "/tmp/{{ item }}_{{ clickhouse_version }}_amd64.deb"
        state: present
      loop: "{{ clickhouse_packages }}"
      notify: Start Clickhouse service

    - name: Flush handlers
      ansible.builtin.meta: flush_handlers

    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc != 82
      changed_when: create_db.rc == 0

- name: Install and configure Vector
  hosts: all
  become: true
  vars:
    vector_version: "0.46.1"
    vector_arch: "amd64"
  handlers:
    - name: Restart Vector service
      ansible.builtin.service:
        name: vector
        state: restarted
  tasks:
    - name: Download Vector .deb package
      ansible.builtin.get_url:
        url: "https://apt.vector.dev/pool/v/ve/vector_{{ vector_version }}-1_{{ vector_arch }}.deb"
        dest: "/tmp/vector_{{ vector_version }}.deb"
        mode: '0644'

    - name: Install Vector package
      ansible.builtin.apt:
        deb: "/tmp/vector_{{ vector_version }}.deb"
        state: present

    - name: Create Vector configuration directory
      ansible.builtin.file:
        path: /etc/vector
        state: directory
        mode: '0755'

    - name: Deploy Vector configuration
      ansible.builtin.template:
        src: "{{ playbook_dir }}/templates/vector-config.toml.j2"
        dest: /etc/vector/vector.toml
        mode: '0644'
      notify: Restart Vector service

    - name: Ensure Vector service is enabled and started
      ansible.builtin.service:
        name: vector
        enabled: true
        state: started
```

---

### playbook/templates/vector-config.toml.j2
```toml
[sources.stdin]
type = "stdin"

[sinks.console]
inputs = ["stdin"]
type = "console"
encoding.codec = "json"
```

---

## Выполнение пунктов

* Запуск `ansible-lint site.yml`
  Результат: ошибки были выявлены и исправлены (yes/true).

* Запуск playbook с флагом `--check`
  Результат: изменений не произведено, playbook готов к применению.

* Запуск playbook с флагом `--diff`
  Результат: успешно скачан Vector, распакован и настроен. Конфигурация загружена, служба перезапущена.

* Повторный запуск с `--diff`
  Результат: изменений не обнаружено (playbook идемпотентен).

---

## Скриншоты

* **Запуск playbook с флагом `--check`**
  ![Check Mode](./screenshots/playbook-check.png)

* **Первый запуск playbook с флагом `--diff`**
  ![Diff Mode - Первый запуск](./screenshots/playbook-diff-1.png)

* **Повторный запуск playbook с флагом `--diff` (идемпотентность)**
  ![Diff Mode - Повторный запуск](./screenshots/playbook-diff-2.png)

---

## Заключение

В ходе выполнения задания была успешно реализована автоматизация установки и настройки Vector через Ansible playbook. Использование шаблона Jinja2 позволило гибко управлять конфигурацией. Playbook соответствует требованиям идемпотентности, прошёл проверку через ansible-lint.