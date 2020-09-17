---
title: 1.SpringMVC使用示例
date: 2019-10-30 12:00:00
tags:
- Java
- 源码
- SpringMVC
categories:
- SPRING
---

SpringMVC项目的演示示例，包含 maven 依赖配置，web.xml 文件配置，spring-mvc.xml 文件配置等，代码部分省略。

<!-- more -->

# 创建maven工程

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0http://maven.apache.org/maven-v4_0_0.xsd">
    <parent>
        <artifactId>spring-all</artifactId>
        <groupId>cn.cuilan</groupId>
        <version>1.0.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>
    <artifactId>spring-mvc</artifactId>
    <packaging>war</packaging>
    <name>spring-mvc</name>
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-webmvc</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context-support</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.freemarker</groupId>
            <artifactId>freemarker</artifactId>
            <version>${freemarker.version}</version>
        </dependency>
    </dependencies>
    <build>
        <finalName>spring-mvc</finalName>
        <resources>
            <resource>
                <directory>src/main/java</directory>
            </resource>
            <resource>
                <directory>src/main/resources</directory>
            </resource>
            <resource>
                <directory>src/main/webapp</directory>
            </resource>
        </resources>
        <plugins>
            <plugin>
                <artifactId>maven-war-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

# 创建 `spring-mvc.xml` 配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans  xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:context="http://www.springframework.org/schema/context"
        xsi:schemaLocation="
        http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd">
    <!-- 开启组件自动扫描 -->
    <context:component-scan base-package="cn.cuilan"/>
    <mvc:annotation-driven/>

    <!-- freemarker配置类 -->
    <bean id="freeMarkerConfigurer"
			class="org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer">
        <property name="templateLoaderPath" value="/WEB-INF/ftl/"/>
        <property name="defaultEncoding" value="UTF-8"/>
        <property name="freemarkerSettings">
            <props>
                <prop key="locale">zh_CN</prop>
            </props>
        </property>
    </bean>

    <!-- freemarker视图解析器 -->
    <bean id="freeMarkerViewResolver"
			class="org.springframework.web.servlet.view.freemarker.FreeMarkerViewResolver">
        <property name="cache" value="true"/>
        <property name="prefix" value=""/><!-- 上面配置，此处不能重复配置 -->
        <property name="suffix" value=".ftl"/>
        <property name="contentType" value="text/html;charset=UTF-8"/>
        <property name="allowSessionOverride" value="true"/>
        <property name="allowRequestOverride" value="true"/>
        <property name="exposeSpringMacroHelpers" value="true"/>
        <property name="exposeRequestAttributes" value="true"/>
        <property name="exposeSessionAttributes" value="true"/>
        <property name="requestContextAttribute" value="request"/>
    </bean>
</beans>
```

# 配置 `web.xml` 文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
			 http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         metadata-complete="true" version="3.1">
    <display-name>spring-mvc</display-name>
    <servlet>
        <servlet-name>dispatcherServlet</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:spring-mvc.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>dispatcherServlet</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>
</web-app>
```
